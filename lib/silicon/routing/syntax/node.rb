module Syntax
  class Node < Treetop::Runtime::SyntaxNode
    attr_accessor :route, :actions, :my_nodes, :parent_node, :level, :before_commands, :after_commands

    def parse(parent_node = nil)
      @parent_node = parent_node

      elements.each do |element|
        if element.is_a? Indent
          @level = element.elements.length
        end

        if element.is_a? Route
          @route = element.parse(self)
        end

        if element.is_a? Actions
          @actions = element.parse(self)
        end

        if element.is_a? Nodes
          @my_nodes = element.parse(self)
        end

        if element.is_a? BeforeSection
          @before_commands = element.parse.commands
        end

        if element.is_a? AfterSection
          @after_commands = element.parse.commands
        end
      end

      self
    end

    def to_hash
      {
        route: @route.to_hash,
        actions: @actions,
        level: @level,
        before: @before_commands,
        after: @after_commands
      }
    end
  end
end