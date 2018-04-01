module Syntax
  class HttpStatus < Treetop::Runtime::SyntaxNode
    def parse
      result = nil

      unless text_value.empty?
        result = text_value.sub('=', '').to_i
      end

      result
    end
  end
end