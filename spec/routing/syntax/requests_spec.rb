require 'spec_helper'
require 'dandy/routing/syntax/requests'
require 'dandy/routing/syntax/catch_section'
require 'dandy/routing/syntax/node'


RSpec.describe Syntax::Requests do
  describe 'parse' do
    it 'correctly sets node and catch sections' do
      requests = Syntax::Requests.new('some-text', 2)
      element = double(:element)
      node_element = Syntax::Node.new('some-text', 2)
      catch_section_element = Syntax::CatchSection.new('some-text', 2)
      node = double(:node)
      catch = double(:catch)

      allow(node_element).to receive(:parse).and_return(node)
      allow(catch_section_element).to receive(:parse).and_return(catch)
      allow(requests).to receive(:elements).and_return([catch_section_element, element, node_element])

      requests.parse
      expect(requests.node).to eql(node)
      expect(requests.catch).to eql(catch)
    end
  end
end

