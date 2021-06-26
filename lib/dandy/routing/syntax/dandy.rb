module Syntax
  class Dandy < Treetop::Runtime::SyntaxNode
    attr_reader :requests, :messages

    def parse
      elements.each do |element|
        element.elements.each do |nested|
          if nested.is_a? Requests
            @requests = nested.parse
          end

          if nested.is_a? Messages
            @messages = nested.parse
          end
        end
      end
      self
    end
  end
end