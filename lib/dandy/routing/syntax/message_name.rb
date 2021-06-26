module Syntax
  class MessageName < Treetop::Runtime::SyntaxNode
    def parse
      text_value.gsub('"','')
    end
  end
end