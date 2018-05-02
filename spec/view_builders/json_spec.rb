require 'spec_helper'
require 'dandy/view_builders/json'

RSpec.describe Dandy::ViewBuilders::Json do
  describe 'build' do
    before :each do
      @user = {user_name: 'Dandy'}
      @template = 'json.user_name @user[:user_name]'
      @container = double(:container)

    end
    context 'when camel keys are not required' do
      it 'builds json output as is' do
        builder = Dandy::ViewBuilders::Json.new(@template, @container, {})
        builder.instance_variable_set('@user', @user)
        expect(builder.build).to eql('{"user_name":"Dandy"}')
      end
    end

    context 'when camel keys are required' do
      it 'builds json output with camelized keys' do
        builder = Dandy::ViewBuilders::Json.new(@template, @container, {keys_format: 'camel'})
        builder.instance_variable_set('@user', @user)
        expect(builder.build).to eql('{"userName":"Dandy"}')
      end
    end
  end
end