module Syntax
  class Route < Treetop::Runtime::SyntaxNode
    attr_reader :node, :path, :parameter

    def parse(node)
      @node = node

      elements.each do |element|
        if element.is_a? Parameter
          @parameter = element.text_value
        end

        if element.is_a? Path
          @path = element.text_value
        end
      end

      self
    end

    def to_hash
      {path: @path, parameter: @parameter}
    end
  end
end