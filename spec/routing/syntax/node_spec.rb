require 'spec_helper'
require 'dandy/routing/syntax/route'
require 'dandy/routing/syntax/primitives/indent'
require 'dandy/routing/syntax/primitives/http_verb'
require 'dandy/routing/syntax/nodes'
require 'dandy/routing/syntax/actions'
require 'dandy/routing/syntax/after_section'
require 'dandy/routing/syntax/before_section'

RSpec.describe Syntax::Node do
  describe 'parse' do
    it 'correctly sets commands, http_verb and respond' do
      node = Syntax::Node.new('some-text', 2)

      route = double(:route)
      nodes = double(:nodes)
      actions = double(:actions)
      parent_node = double(:parent_node)

      before_commands = %w(before1 before2)
      before_section = double(:before_section)
      allow(before_section).to receive(:commands).and_return(before_commands)

      after_commands = %w(after1 after2)
      after_section = double(:after_section)
      allow(after_section).to receive(:commands).and_return(after_commands)

      indents = ['^']

      route_element = Syntax::Route.new('some-text', 2)
      indent_element = Syntax::Indent.new('some-text', 2)
      nodes_element = Syntax::Nodes.new('some-text', 2)
      actions_element = Syntax::Actions.new('some-text', 2)
      before_section_element = Syntax::BeforeSection.new('some-text', 2)
      after_section_element = Syntax::AfterSection.new('some-text', 2)

      allow(route_element).to receive(:parse).and_return(route)
      allow(indent_element).to receive(:elements).and_return(indents)
      allow(nodes_element).to receive(:parse).and_return(nodes)
      allow(actions_element).to receive(:parse).and_return(actions)
      allow(before_section_element).to receive(:parse).and_return(before_section)
      allow(after_section_element).to receive(:parse).and_return(after_section)

      elements = [
        route_element, after_section_element, indent_element,
        actions_element, nodes_element, before_section_element
      ]
      allow(node).to receive(:elements).and_return(elements)

      node.parse(parent_node)
      expect(node.parent_node).to eql(parent_node)
      expect(node.route).to eql(route)
      expect(node.actions).to eql(actions)
      expect(node.my_nodes).to eql(nodes)
      expect(node.level).to eql(indents.length)
      expect(node.before_commands).to eql(before_commands)
      expect(node.after_commands).to eql(after_commands)
    end
  end

  describe 'to_hash' do
    it 'returns correct hash representation' do
      node = Syntax::Node.new('some-text', 2)

      route = double(:route)
      route_hash = {}
      allow(route).to receive(:to_hash).and_return(route_hash)

      node.instance_variable_set('@route', route)
      node.instance_variable_set('@actions', ['action 1', 'action 2'])
      node.instance_variable_set('@level', 2)
      node.instance_variable_set('@before_commands', ['before 1', 'before 2'])
      node.instance_variable_set('@after_commands', ['after 1', 'after 2'])

      hash = node.to_hash

      expect(hash[:route]).to eql(route_hash)
      expect(hash[:actions]).to eql(['action 1', 'action 2'])
      expect(hash[:level]).to eql(2)
      expect(hash[:before]).to eql(['before 1', 'before 2'])
      expect(hash[:after]).to eql(['after 1', 'after 2'])
    end
  end
end

