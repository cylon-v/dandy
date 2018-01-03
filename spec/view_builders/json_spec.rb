require 'spec_helper'
require 'silicon/view_builders/json'

RSpec.describe Silicon::ViewBuilders::Json do
  describe 'build' do
    it 'builds json output' do
      user = {name: 'Silicon'}
      template = 'json.merge! @user'
      container = double(:container)

      builder = Silicon::ViewBuilders::Json.new(template, container)
      builder.instance_variable_set('@user', user)
      expect(builder.build).to eql('{"name":"Silicon"}')
    end
  end
end