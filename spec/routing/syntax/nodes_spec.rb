require 'spec_helper'
require 'silicon/routing/syntax/nodes'

RSpec.describe Syntax::Nodes do
  describe 'parse' do
    it 'correctly parses nodes' do
      nodes = Syntax::Nodes.new('some-text', 2)

      element1 = double(:element1)
      element2 = double(:element2)
      allow(element1).to receive(:parse).and_return('result 1')
      allow(element2).to receive(:parse).and_return('result 2')

      allow(nodes).to receive(:elements).and_return([element1, element2])

      node = double(:node)
      expect(nodes.parse(node)).to eql(['result 1', 'result 2'])
    end
  end
end
