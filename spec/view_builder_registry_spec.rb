require 'spec_helper'
require 'silicon/errors/silicon_error'
require 'silicon/view_builder'
require 'silicon/view_builder_registry'
require 'silicon/view_builders/json'

RSpec.describe Silicon::ViewBuilderRegistry do
  describe 'add / get' do
    before :each do
      @registry = Silicon::ViewBuilderRegistry.new
    end

    context 'when parameter is not a view builder' do
      it 'raises SiliconError' do
        class Unexpected; end
        expect{@registry.add(Unexpected, '.xdx')}.to raise_error(Silicon::SiliconError)
      end
    end

    context 'when parameter is a view builder' do
      it 'adds it to the registry' do
        @registry.add(Silicon::ViewBuilders::Json, 'json')

        expect(@registry.get('json')).to eql(Silicon::ViewBuilders::Json)
      end
    end
  end
end
