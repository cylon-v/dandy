module Syntax
  class Sections < Treetop::Runtime::SyntaxNode
    attr_reader :node, :catch

    def parse
      elements.each do |element|
        if element.is_a? Node
          @node = element.parse
        end

        if element.is_a? CatchSection
          @catch = element.parse
        end
      end

      self
    end
  end
end