require 'spec_helper'
require 'dandy/routing/syntax/sections'
require 'dandy/routing/syntax/primitives/http_status'
require 'dandy/routing/syntax/view'


RSpec.describe Syntax::Respond do
  describe 'parse' do
    it 'correctly sets view and http_status' do
      respond = Syntax::Respond.new('some-text', 2)
      element = double(:element)
      view_element = Syntax::View.new('some-text', 2)
      http_status_element = Syntax::HttpStatus.new('some-text', 2)
      view = double(:view)
      http_status = double(:http_status)

      level2 = double(:level2)
      allow(level2).to receive(:elements).and_return([view_element, element, http_status_element])

      level1 = double(:level1)
      allow(level1).to receive(:elements).and_return([{}, level2])


      allow(view_element).to receive(:parse).and_return(view)
      allow(http_status_element).to receive(:parse).and_return(http_status)
      allow(respond).to receive(:elements).and_return([level1])

      respond.parse
      expect(respond.view).to eql(view)
      expect(respond.http_status).to eql(http_status)
    end
  end

  describe 'to_hash' do
    it 'returns correct hash representation' do
      route = Syntax::Respond.new('some-text', 2)
      route.instance_variable_set('@view','some_view')
      route.instance_variable_set('@http_status', 200)

      expect(route.to_hash[:view]).to eql('some_view')
      expect(route.to_hash[:http_status]).to eql(200)
    end
  end
end

