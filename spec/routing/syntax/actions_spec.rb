require 'spec_helper'
require 'dandy/routing/syntax/actions'

RSpec.describe Syntax::Actions do
  describe 'parse' do
    it 'correctly parses name' do
      actions = Syntax::Actions.new('some-text', 2)

      element1 = double(:element1)
      element2 = double(:element2)

      action1 = double(:action1)
      action2 = double(:action2)

      allow(action1).to receive(:to_hash).and_return({http_verb: 'GET'})
      allow(action2).to receive(:to_hash).and_return({http_verb: 'POST'})

      allow(element1).to receive(:parse).and_return(action1)
      allow(element2).to receive(:parse).and_return(action2)
      node = double(:node)

      allow(actions).to receive(:elements).and_return([element1, element2])

      actions.parse(node)
      expect(actions.actions[0][:http_verb]).to eql('GET')
      expect(actions.actions[1][:http_verb]).to eql('POST')
    end
  end
end
