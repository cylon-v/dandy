require 'spec_helper'
require 'silicon/routing/matcher'

RSpec.describe Silicon::Routing::Parser do
  describe 'parse' do
    before :each do
      @file_reader = double(:file_reader)
      @syntax_parser = double(:syntax_parser)
      @syntax_error_interpreter = double(:syntax_error_interpreter)
      @routes_builder = double(:routes_builder)
    end

    context 'when syntax parser returns nil' do
      before :each do
        allow(@file_reader).to receive(:read).and_return '<some routes definition>'
        allow(@syntax_parser).to receive(:parse).and_return nil
        allow(@syntax_error_interpreter).to receive(:interpret).and_return 'error message'

        @parser = Silicon::Routing::Parser.new(
          @file_reader,
          @routes_builder,
          @syntax_parser,
          @syntax_error_interpreter
        )
      end

      it 'raises syntax error with message returned from error detector' do
        expect{@parser.parse}.to raise_error(Silicon::SyntaxError, 'error message')
      end
    end

    context 'when syntax parser returns not nil result' do
      before :each do
        @parsed_tree = double(:parsed_tree)
        @tree = double(:tree)
        allow(@tree).to receive(:parse).and_return(@parsed_tree)

        allow(@file_reader).to receive(:read).and_return '<some routes definition>'
        allow(@syntax_parser).to receive(:parse).and_return @tree
        allow(@routes_builder).to receive(:build)

        @parser = Silicon::Routing::Parser.new(
          @file_reader,
          @routes_builder,
          @syntax_parser,
          @syntax_error_interpreter
        )
      end

      it 'call route builder' do
        expect(@routes_builder).to receive(:build).with(@parsed_tree)
        @parser.parse
      end
    end
  end
end
