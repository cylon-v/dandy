require 'spec_helper'
require 'dandy/view_builders/json'

RSpec.describe Dandy::ViewBuilders::Json do
  describe 'build' do
    it 'builds json output' do
      user = {name: 'Dandy'}
      template = 'json.merge! @user'
      container = double(:container)

      builder = Dandy::ViewBuilders::Json.new(template, container)
      builder.instance_variable_set('@user', user)
      expect(builder.build).to eql('{"name":"Dandy"}')
    end
  end
end