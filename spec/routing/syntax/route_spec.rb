require 'spec_helper'
require 'dandy/routing/syntax/route'
require 'dandy/routing/syntax/primitives/path'
require 'dandy/routing/syntax/primitives/parameter'


RSpec.describe Syntax::Route do
  describe 'parse' do
    it 'correctly sets node, parameter and path' do
      route = Syntax::Route.new('some-text', 2)
      element = double(:element)
      parameter_element = Syntax::Parameter.new('some-text', 2)
      path_element = Syntax::Path.new('some-text', 2)
      parameter = double(:parameter)
      path = double(:path)
      node = double(:node)

      allow(parameter_element).to receive(:text_value).and_return(parameter)
      allow(path_element).to receive(:text_value).and_return(path)
      allow(route).to receive(:elements).and_return([parameter_element, element, path_element])

      route.parse(node)
      expect(route.node).to eql(node)
      expect(route.parameter).to eql(parameter)
      expect(route.path).to eql(path)
    end
  end

  describe 'to_hash' do
    it 'returns correct hash representation' do
      route = Syntax::Route.new('some-text', 2)
      route.instance_variable_set('@path','/path')
      route.instance_variable_set('@parameter','$param')

      expect(route.to_hash[:path]).to eql('/path')
      expect(route.to_hash[:parameter]).to eql('$param')
    end
  end
end

