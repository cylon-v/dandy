require 'spec_helper'
require 'dandy/errors/dandy_error'
require 'dandy/view_builder'
require 'dandy/view_builder_registry'
require 'dandy/view_builders/json'

RSpec.describe Dandy::ViewBuilderRegistry do
  describe 'add / get' do
    before :each do
      @registry = Dandy::ViewBuilderRegistry.new
    end

    context 'when parameter is not a view builder' do
      it 'raises DandyError' do
        class Unexpected; end
        expect{@registry.add(Unexpected, '.xdx')}.to raise_error(Dandy::DandyError)
      end
    end

    context 'when parameter is a view builder' do
      it 'adds it to the registry' do
        @registry.add(Dandy::ViewBuilders::Json, 'json')

        expect(@registry.get('json')).to eql(Dandy::ViewBuilders::Json)
      end
    end
  end
end
