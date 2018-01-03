require 'timeout'

module Silicon
  class Chain
    def initialize(container, silicon_config, commands, catch_command = nil)
      @commands = commands
      @container = container
      @catch_command = catch_command
      @async_timeout = silicon_config[:action][:async_timeout]
    end

    def execute
      if @catch_command.nil?
        run_actions
      else
        begin
          run_actions
        rescue Exception => error
          @container
            .register_instance(error, :silicon_error)
            .using_lifetime(:scope)
            .bound_to(:silicon_request)

          action = @container.resolve(@catch_command.name.to_sym)
          action.call
        end
      end
    end

    private

    def run_actions
      threads = []
      Thread.abort_on_exception = true
      @commands.each_with_index do |command, index|
        if command.sequential?
          # all previous parallel commands should be done before the current sequential
          threads.each {|t| t.join}
          threads = []

          run_action(command.name)
        else
          thread = Thread.new {
            Timeout::timeout(@async_timeout) {
              run_action(command.name)
            }
          }
          threads << thread if command.parallel?
        end

        # if it's last item in chain then wait until parallel commands are done
        if index == @commands.length - 1
          threads.each {|t| t.join}
        end
      end
    end

    def run_action(name)
      action = @container.resolve(name.to_sym)
      result = action.call
      result_name = action.respond_to?(:result_name) ? action.result_name : "#{name}_result"

      @container
        .register_instance(result, result_name.to_sym)
        .using_lifetime(:scope)
        .bound_to(:silicon_request)
    end
  end
end