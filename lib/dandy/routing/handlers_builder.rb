require 'dandy/routing/message_handler'

module Dandy
  module Routing
    class HandlersBuilder
      def initialize
        @parsed_items = []
        @route_params = []
        @current_parent = nil
        @prev_route = nil
      end

      def build(messages)
        messages.map do |message|
          MessageHandler.new({
            catch: messages.catch.command,
            last_command: message[:commands].last,
            commands: messages[:before] + message[:commands] + messages[:after]
          })
        end
      end
    end
  end
end