module Dandy
  module Routing
    class Route
      attr_reader :http_verb, :path, :params, :catch,
                  :commands, :segments, :view, :http_status, :last_command

      def initialize(hash)
        @http_verb = hash[:http_verb]

        @path = hash[:path].sub('.', '/').sub('//', '/')

        @params = hash[:params]
        @commands = hash[:commands]
        @last_command = hash[:last_command]
        @view = hash[:view]
        @http_status = hash[:http_status]

        @segments = @path.split('/').concat(['/'])

        @catch = hash[:catch]
      end
    end
  end
end