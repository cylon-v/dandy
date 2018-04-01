module Syntax
  class Action < Treetop::Runtime::SyntaxNode
    attr_reader :http_verb, :commands, :node, :respond

    def parse(node)
      @node = node
      @commands = []

      elements.each do |element|
        if element.is_a? HttpVerb
          @http_verb = element.text_value
        end

        if element.is_a? Commands
          @commands = element.parse
        end

        if element.is_a? Respond
          @respond = element.parse
        end
      end

      self
    end

    def to_hash
      {http_verb: @http_verb, commands: @commands, view: @respond.view, http_status: @respond.http_status}
    end
  end
end