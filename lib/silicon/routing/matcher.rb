require 'silicon/routing/match'

module Silicon
  module Routing
    class Matcher
      def initialize(routes)
        @routes = routes
      end

      def match(path, http_method)
        segments = path.split('/').concat(['/'])
        params = {}
        matched = nil

        @routes.each do |route|
          if route.segments.length == segments.length
            for i in 0..segments.length - 1 do
              template = route.segments[i]
              value = segments[i]

              if value == template
              elsif template.index('$') == 0
                name = template.sub('$', '')
                params[name] = value
              else
                break
              end

              if i == segments.length - 1 && route.http_verb == http_method
                matched = route
              end
            end
          end
        end

        matched.nil? ? nil : Match.new(matched, params)
      end
    end
  end
end
