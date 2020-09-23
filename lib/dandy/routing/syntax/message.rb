module Syntax
  class Message < Treetop::Runtime::SyntaxNode
    attr_accessor :name, :command_list

    def parse
      elements.each do |element|
        if element.is_a? MessageName
          @name = element.parse
        end

        if element.is_a? Commands
          @command_list = element.parse
        end
      end

      self
    end
  end
end