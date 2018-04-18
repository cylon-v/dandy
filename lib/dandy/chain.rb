require 'timeout'

module Dandy
  class Chain
    def initialize(container, dandy_config, commands, catch_command = nil)
      @commands = commands
      @container = container
      @catch_command = catch_command
      @async_timeout = dandy_config[:action][:async_timeout]
    end

    def execute
      if @catch_command.nil?
        run_commands
      else
        begin
          run_commands
        rescue Exception => error
          @container
            .register_instance(error, :dandy_error)
            .using_lifetime(:scope)
            .bound_to(:dandy_request)

          action = @container.resolve(@catch_command.name.to_sym)
          action.call
        end
      end
    end

    private

    def run_commands
      threads = []
      Thread.abort_on_exception = true

      result = nil
      @commands.each_with_index do |command, index|
        if command.sequential?
          # all previous parallel commands should be done before the current sequential
          threads.each {|t| t.join}
          threads = []

          result = run_command(command)
        else
          thread = Thread.new {
            Timeout::timeout(@async_timeout) {
              result = run_command(command)
            }
          }
          threads << thread if command.parallel?
        end

        # if it's last item in chain then wait until parallel commands are done
        if index == @commands.length - 1
          threads.each {|t| t.join}
        end
      end

      result
    end

    def run_command(command)
      action = @container.resolve(command.name.to_sym)
      result = action.call

      @container
        .register_instance(result, command.result_name.to_sym)
        .using_lifetime(:scope)
        .bound_to(:dandy_request)

      result
    end
  end
end