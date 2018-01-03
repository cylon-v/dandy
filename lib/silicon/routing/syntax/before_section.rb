module Syntax
  class BeforeSection < Treetop::Runtime::SyntaxNode
    attr_reader :commands

    def parse
      @commands = []
      if elements.length > 0
        elements[0].elements.each do |element|
          if element.is_a? Commands
            @commands = element.parse
          end
        end
      end

      self
    end
  end
end