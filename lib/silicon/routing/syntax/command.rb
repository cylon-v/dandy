module Syntax
  class Command < Treetop::Runtime::SyntaxNode
    attr_reader :name

    def parse
      @is_async = text_value.start_with? '=*'
      @is_parallel = text_value.start_with? '=>'
      @is_sequential = text_value.start_with? '*>'

      @name = text_value.sub('*>', '').sub('=*', '').sub('=>', '')

      self
    end

    def async?
      @is_async
    end

    def parallel?
      @is_parallel
    end

    def sequential?
      @is_sequential
    end
  end
end