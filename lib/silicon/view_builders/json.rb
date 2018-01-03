require 'jbuilder'
require 'silicon/view_builder'

module Silicon
  module ViewBuilders
    class Json < Silicon::ViewBuilder
      def build
        result = Jbuilder.new do |json|
          eval(@template)
        end

        result.target!
      end
    end
  end
end