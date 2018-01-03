require 'silicon/errors/syntax_error'

module Silicon
  module Routing
    class SyntaxErrorInterpreter
      def initialize(syntax_parser)
        @syntax_parser = syntax_parser
      end

      def interpret
        line_num = 1
        (0..@syntax_parser.max_terminal_failure_index - 1).each {|i|
          line_num += 1 if @syntax_parser.input[i] == ';'
        }

        message = "Syntax error in routes definition, line #{line_num}. Expected: "
        expected = []
        @syntax_parser.terminal_failures.each do |f|
          item = f.expected_string
                   .gsub('^', '<space>/<tab>')
                   .gsub(';', '<new line>')
          expected << item
        end
        message + expected.join(', ') + '.'
      end
    end
  end
end