module Syntax
  class CatchSection < Treetop::Runtime::SyntaxNode
    attr_reader :command

    def parse
      elements[0].elements.each do |element|
        if element.is_a? Command
          @command = element.parse
        end
      end

      self
    end
  end
end