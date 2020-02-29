module Syntax
  class Messages < Treetop::Runtime::SyntaxNode
    attr_reader :messages, :catch

    def parse
      elements.each do |element|
        if element.is_a? Message
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