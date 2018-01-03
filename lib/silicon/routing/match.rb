module Silicon
  module Routing
    class Match
      attr_reader :route, :params

      def initialize(route, params)
        @route = route
        @params = params
      end
    end
  end
end
