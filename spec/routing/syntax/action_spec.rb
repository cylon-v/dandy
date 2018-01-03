require 'spec_helper'
require 'silicon/routing/syntax/action'
require 'silicon/routing/syntax/respond'
require 'silicon/routing/syntax/commands'
require 'silicon/routing/syntax/primitives/http_verb'
require 'silicon/routing/syntax/view'


RSpec.describe Syntax::Action do
  describe 'parse' do
    it 'correctly sets commands, http_verb and respond' do
      action = Syntax::Action.new('some-text', 2)

      commands = double(:commands)
      http_verb = double(:http_verb)
      respond = double(:respond)
      node = double(:node)

      commands_element = Syntax::Commands.new('some-text', 2)
      http_verb_element = Syntax::HttpVerb.new('some-text', 2)
      respond_element = Syntax::Respond.new('some-text', 2)

      allow(commands_element).to receive(:parse).and_return(commands)
      allow(http_verb_element).to receive(:text_value).and_return(http_verb)
      allow(respond_element).to receive(:parse).and_return(respond)

      allow(action).to receive(:elements).and_return([commands_element, http_verb_element, respond_element])

      action.parse(node)
      expect(action.commands).to eql(commands)
      expect(action.http_verb).to eql(http_verb)
      expect(action.respond).to eql(respond)
    end
  end

  describe 'to_hash' do
    it 'returns correct hash representation' do
      respond = double(:respond)
      allow(respond).to receive(:view).and_return('some_view')
      allow(respond).to receive(:http_status).and_return(200)

      route = Syntax::Action.new('some-text', 2)
      route.instance_variable_set('@commands', ['command'])
      route.instance_variable_set('@respond', respond)
      route.instance_variable_set('@http_verb', 'PATCH')

      expect(route.to_hash[:view]).to eql('some_view')
      expect(route.to_hash[:http_status]).to eql(200)
      expect(route.to_hash[:commands]).to eql(['command'])
      expect(route.to_hash[:http_verb]).to eql('PATCH')
    end
  end
end

