require 'spec_helper'
require 'dandy/routing/matcher'

RSpec.describe Dandy::Routing::HandlerParser do
  describe 'parse' do
    let(:file_reader) { double(:file_reader) }
    let(:syntax_parser) { double(:syntax_parser) }
    let(:syntax_error_interpreter) { double(:syntax_error_interpreter) }
    let(:handlers_builder) { double(:handlers_builder) }

    let :parser do
      described_class.new(
        file_reader,
        handlers_builder,
        syntax_parser,
        syntax_error_interpreter
      )
    end

    context 'when syntax parser returns nil' do
      before :each do
        allow(file_reader).to receive(:read).and_return '<some routes definition>'
        allow(syntax_parser).to receive(:parse).and_return nil
        allow(syntax_error_interpreter).to receive(:interpret).and_return 'error message'
      end

      it 'raises syntax error with message returned from error detector' do
        expect{parser.parse}.to raise_error(Dandy::SyntaxError, 'error message')
      end
    end

    context 'when syntax parser returns not nil result' do
      let(:parsed_tree) { double(:parsed_tree) }
      let(:tree) { double(:tree) }
      let(:messages) { double(:messages) }

      before :each do
        allow(parsed_tree).to receive(:messages).and_return(messages)
      end

      let(:parser) do
        described_class.new(
          file_reader,
          handlers_builder,
          syntax_parser,
          syntax_error_interpreter
        )
      end

      before :each do
        allow(tree).to receive(:parse).and_return(parsed_tree)

        allow(file_reader).to receive(:read).and_return '<some routes definition>'
        allow(syntax_parser).to receive(:parse).and_return tree
        allow(handlers_builder).to receive(:build)
      end

      it 'call route builder' do
        expect(handlers_builder).to receive(:build).with(messages)
        parser.parse
      end
    end
  end
end
