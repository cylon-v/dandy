module Syntax
  class Command < Treetop::Runtime::SyntaxNode
    attr_reader :name, :result_name

    def parse
      @is_async = text_value.start_with? '=*'
      @is_parallel = text_value.start_with? '=>'
      @is_sequential = text_value.start_with? '*>'

      full_name = text_value.sub('*>', '').sub('=*', '').sub('=>', '')

      if full_name.include? '@'
        parts = full_name.split('@')
        @result_name = parts[0]
        @name = parts[1]
      else
        @name = full_name
      end

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