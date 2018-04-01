require 'jbuilder'
require 'dandy/view_builder'

module Dandy
  module ViewBuilders
    class Json < Dandy::ViewBuilder
      def build
        result = Jbuilder.new do |json|
          eval(@template)
        end

        result.target!
      end
    end
  end
end