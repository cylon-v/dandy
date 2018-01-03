require 'spec_helper'
require 'silicon/routing/syntax/tree_section'

RSpec.describe Syntax::TreeSection do
  describe 'parse' do
    it 'correctly sets node attribute' do
      tree_section = Syntax::TreeSection.new('some-text', 2)
      element = double(:element)
      node_element = double(:node_element)
      parsed_result = double(:parsed_result)

      allow(node_element).to receive(:parse).and_return(parsed_result)
      allow(tree_section).to receive(:elements).and_return([element, element, node_element])

      tree_section.parse
      expect(tree_section.node).to eql(parsed_result)
    end
  end
end

