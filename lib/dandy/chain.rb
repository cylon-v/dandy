require 'timeout'

module Dandy
  class Chain
    def initialize(container, dandy_config)
      @container = container
      @async_timeout = dandy_config[:action][:async_timeout]
    end

    def run_commands(commands, last_command)
      threads = []
      Thread.abort_on_exception = true

      result = nil
      commands.each_with_index do |command, index|
        if command.sequential?
          # all previous parallel commands should be done before the current sequential
          threads.each {|t| t.join}
          threads = []

          if last_command && (command.name == last_command.name)
            result = run_command(command)
          else
            run_command(command)
          end
        else
          thread = Thread.new {
            Timeout::timeout(@async_timeout) {
              if last_command && (command.name == last_command.name)
                result = run_command(command)
              else
                run_command(command)
              end
            }
          }
          threads << thread if command.parallel?
        end

        # if it's last item in chain then wait until parallel commands are done
        if index == commands.length - 1
          threads.each {|t| t.join}
        end
      end

      result
    end

    private

    def run_command(command)
      if command.entity?
        entity = @container.resolve(command.entity_name.to_sym)
        method_name = command.entity_method.to_sym

        param_names = entity.class.instance_method(method_name).parameters.map(&:last)
        params = param_names.map {|param_name| @container.resolve(param_name)}

        result = entity.public_send(method_name, *params)
      else
        action = @container.resolve(command.name.to_sym)
        result = action.call
      end


      @container
        .register_instance(result, command.result_name.to_sym)
        .using_lifetime(:scope)
        .bound_to(:dandy_request)

      result
    end
  end
end