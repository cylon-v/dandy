module Syntax
  class View < Treetop::Runtime::SyntaxNode
    def parse
      text_value.sub('<*', '')
    end
  end
end