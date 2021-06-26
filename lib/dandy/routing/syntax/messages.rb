module Syntax
  class Messages < Treetop::Runtime::SyntaxNode
    attr_reader :messages, :catch, :before_commands, :after_commands

    def parse
      @messages ||= []
      @before_commands = []
      @after_commands = []

      elements.each do |element|
        if element.elements
          element.elements.each do |nested|
            if nested.is_a? Message
              @messages << nested.parse
            end
          end
        end

        if element.is_a? BeforeSection
          @before_commands = element.parse.commands
        end

        if element.is_a? AfterSection
          @after_commands = element.parse.commands
        end

        if element.is_a? CatchSection
          @catch = element.parse
        end
      end

      self
    end
  end
end