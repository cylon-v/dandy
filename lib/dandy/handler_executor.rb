module Dandy
  class HandlerExecutor
    def initialize(container, dandy_config)
      @container = container
      @dandy_config = dandy_config
    end

    def execute(message_handler)
      chain = Chain.new(@container, @dandy_config)

      begin
        chain.run_commands(message_handler.commands, message_handler.last_command)
      rescue Exception => error
        p error
        handle_error(message_handler, error)
      end
    end

    def handle_error(message_handler, error)
      @container
        .register_instance(error, :dandy_error)
        .using_lifetime(:scope)
        .bound_to(:dandy_request)

      command = @container.resolve(message_handler.catch.name.to_sym)
      command.call
    end
  end
end