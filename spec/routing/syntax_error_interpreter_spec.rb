require 'spec_helper'
require 'silicon/routing/syntax_error_interpreter'

RSpec.describe Silicon::Routing::SyntaxErrorInterpreter do
  describe 'interpret' do
    before :each do
      @syntax_parser = double(:syntax_parser)
      @syntax_error_interpreter = Silicon::Routing::SyntaxErrorInterpreter.new(@syntax_parser)
    end

    it 'correctly identifies line number where error is detected' do
      allow(@syntax_parser).to receive(:input).and_return 'test line 1; test line 2; test line 3;'
      allow(@syntax_parser).to receive(:terminal_failures).and_return []
      allow(@syntax_parser).to receive(:max_terminal_failure_index).and_return 17

      result = @syntax_error_interpreter.interpret
      expect(result).to eql('Syntax error in routes definition, line 2. Expected: .')
    end

    it 'correctly shows expected statements' do
      allow(@syntax_parser).to receive(:input).and_return 'test line 1; test GET 2; test line 3;'

      space_failure = double(:space_failure)
      allow(space_failure).to receive(:expected_string).and_return '^'

      new_line_failure = double(:new_line_failure)
      allow(new_line_failure).to receive(:expected_string).and_return ';'

      statement_failure = double(:statement_failure)
      allow(statement_failure).to receive(:expected_string).and_return 'GET'


      allow(@syntax_parser).to receive(:terminal_failures).and_return [space_failure, new_line_failure, statement_failure]
      allow(@syntax_parser).to receive(:max_terminal_failure_index).and_return 17

      result = @syntax_error_interpreter.interpret
      expect(result).to eql('Syntax error in routes definition, line 2. Expected: <space>/<tab>, <new line>, GET.')
    end
  end
end
