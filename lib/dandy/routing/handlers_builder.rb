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

      def build(section)
        section.messages.map do |message|
          MessageHandler.new({
            name: message.name,
            catch: section.catch.command,
            last_command: message.command_list.last,
            commands: section.before_commands + message.command_list + section.after_commands
          })
        end
      end
    end
  end
end