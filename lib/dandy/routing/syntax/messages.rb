module Syntax
  class Messages < Treetop::Runtime::SyntaxNode
    attr_reader :messages, :catch

    def parse
      @messages ||= []
      elements.each do |element|
        if element.is_a? BeforeSection
          @before_commands = element.parse.commands
        end

        if element.is_a? AfterSection
          @after_commands = element.parse.commands
        end

        if element.is_a? Message
          @messages << element.parse
        end

        if element.is_a? CatchSection
          @catch = element.parse
        end
      end

      self
    end
  end
end