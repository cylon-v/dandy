module Syntax
  class Message < Treetop::Runtime::SyntaxNode
    attr_accessor :name, :commands, :before_commands, :after_commands

    def parse(parent_node = nil)
      @parent_node = parent_node

      elements.each do |element|
        if element.is_a? MessageName
          @name = element.parse
        end

        if element.is_a? Commands
          @commands = element.parse
        end

        if element.is_a? BeforeSection
          @before_commands = element.parse.commands
        end

        if element.is_a? AfterSection
          @after_commands = element.parse.commands
        end
      end
    end

    def to_hash
      {
        name: @name,
        commands: @commands,
        before: @before_commands,
        after: @after_commands
      }
    end
  end
end