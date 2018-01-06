module Silicon
  module Routing
    class Route
      attr_reader :http_verb, :path, :params, :catch,
                  :commands, :segments, :view, :http_status

      def initialize(hash)
        @http_verb = hash[:http_verb]

        @path = hash[:path].sub('.', '/').sub('//', '/')

        @params = hash[:params]
        @commands = hash[:commands]
        @view = hash[:view]
        @http_status = hash[:http_status]

        @segments = @path.split('/').concat(['/'])

        @catch = hash[:catch]
      end

      def to_hash
        {
          http_verb: @http_verb,
          path: @path,
          params: @params,
          commands: @commands.map{|c| c.name},
          catch: @catch.name
        }
      end
    end
  end
end