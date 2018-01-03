module Syntax
  class Commands < Treetop::Runtime::SyntaxNode
    def parse
      elements.map {|element| element.parse}
    end
  end
end