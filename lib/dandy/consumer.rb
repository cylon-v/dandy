module Dandy
  class Consumer
    def connect(message_handlers, handler_executor)
      @message_handlers = {}
      @handler_executor = handler_executor
      message_handlers.each do |handler|
        @message_handlers[handler.name] = handler
      end
    end

    def handle(message)
      handler = @message_handlers[message]
      @handler_executor.execute(handler)
    end
  end
end