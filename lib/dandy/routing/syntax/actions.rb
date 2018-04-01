module Syntax
  class Actions < Treetop::Runtime::SyntaxNode
    attr_reader :actions

    def parse(node)
      @actions = []

      elements.each do |element|
        @actions << element.parse(node).to_hash
      end

      @actions
    end
  end
end