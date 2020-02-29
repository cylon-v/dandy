module Dandy
  module Routing
    class MessageHandler
      attr_reader :name, :params, :catch,
        :commands, :last_command

      def initialize(hash)
        @name = hash[:name]
        @commands = hash[:commands]
        @last_command = hash[:last_command]
        @catch = hash[:catch]
      end
    end
  end
end