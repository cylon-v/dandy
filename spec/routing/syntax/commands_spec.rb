require 'spec_helper'
require 'dandy/routing/syntax/commands'

RSpec.describe Syntax::Commands do
  describe 'parse' do
    it 'correctly parses commands' do
      commands = Syntax::Commands.new('some-text', 2)

      element1 = double(:element1)
      element2 = double(:element2)
      allow(element1).to receive(:parse).and_return('result 1')
      allow(element2).to receive(:parse).and_return('result 2')

      allow(commands).to receive(:elements).and_return([element1, element2])

      expect(commands.parse).to eql(['result 1', 'result 2'])
    end
  end
end
