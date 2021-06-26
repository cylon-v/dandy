require 'dandy/message'

module Dandy
  class Consumer
    def initialize(container)
      @container = container
    end

    def connect(message_handlers, handler_executor)
      @message_handlers = {}
      @handler_executor = handler_executor

      message_handlers.each do |handler|
        @message_handlers[handler.name] = handler
      end

      subscribe
    end

    def subscribe
      raise DandyError, 'Method subscribe is not implemented in your consumer'
    end

    def handle(message_name, payload)
      if @message_handlers.key? message_name
        handler = @message_handlers[message_name]
        message = Message.new(@container, handler, @handler_executor)
        message.handle(payload)
      end
    end
  end
end