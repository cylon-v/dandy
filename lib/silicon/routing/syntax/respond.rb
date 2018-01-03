module Syntax
  class Respond < Treetop::Runtime::SyntaxNode
    attr_reader :view, :http_status

    def parse
      if elements.length > 0
        elements[0].elements[1].elements.each do |element|
          if element.is_a? View
            @view = element.parse
          end

          if element.is_a? HttpStatus
            @http_status = element.parse
          end
        end
      end

      self
    end

    def to_hash
      {view: @view, http_status: @http_status}
    end
  end
end