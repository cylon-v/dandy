require 'spec_helper'
require 'silicon/routing/syntax/sections'
require 'silicon/routing/syntax/catch_section'
require 'silicon/routing/syntax/node'


RSpec.describe Syntax::Sections do
  describe 'parse' do
    it 'correctly sets node and catch sections' do
      sections = Syntax::Sections.new('some-text', 2)
      element = double(:element)
      node_element = Syntax::Node.new('some-text', 2)
      catch_section_element = Syntax::CatchSection.new('some-text', 2)
      node = double(:node)
      catch = double(:catch)

      allow(node_element).to receive(:parse).and_return(node)
      allow(catch_section_element).to receive(:parse).and_return(catch)
      allow(sections).to receive(:elements).and_return([catch_section_element, element, node_element])

      sections.parse
      expect(sections.node).to eql(node)
      expect(sections.catch).to eql(catch)
    end
  end
end

