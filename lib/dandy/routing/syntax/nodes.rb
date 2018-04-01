module Syntax
  class Nodes < Treetop::Runtime::SyntaxNode
    def parse(node)
      nodes = []

      elements.each do |element|
        nodes << element.parse(node)
      end

      nodes
    end
  end
end