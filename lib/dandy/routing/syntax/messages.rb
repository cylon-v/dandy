module Syntax
  class Messages < Treetop::Runtime::SyntaxNode
    attr_reader :messages, :catch, :before_commands, :after_commands

    def parse
      @messages ||= []
      elements.each do |element|
        element.elements do |nested|
          if nested.is_a? Message
            @messages << nested.parse
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