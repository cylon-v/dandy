module Syntax
  class TreeSection < Treetop::Runtime::SyntaxNode
    attr_reader :node

    def parse
      @node = elements[2].parse

      self
    end
  end
end