module Dandy
  module Routing
    class WebParser
      def initialize(file_reader, routes_builder,
                     syntax_parser, syntax_error_interpreter)
        @file_reader = file_reader
        @routes_builder = routes_builder
        @syntax_parser = syntax_parser
        @syntax_error_interpreter = syntax_error_interpreter
      end

      def parse
        content = @file_reader.read
        tree = @syntax_parser.parse(content)

        if tree.nil?
          error_message = @syntax_error_interpreter.interpret
          raise Dandy::SyntaxError, error_message
        end

        dandy = tree.parse

        result = {}
        if dandy.requests
          result[:routes] = @routes_builder.build(dandy.requests)
        end

        result
      end
    end
  end
end