require 'spec_helper'
require 'silicon/loaders/dependency_loader'
require 'silicon/chain_factory'
require 'hypo'

RSpec.describe Silicon::DependencyLoader do
  describe 'load_components' do
    before :each do
      @container = double(:container)
      @type_loader = double(:type_loader)

      @type1 = double(:type1)
      @type2 = double(:type2)

      allow(@type_loader).to receive(:load_types).and_return([@type1, @type2])
      allow(@container).to receive(:register).and_return(@container)
      allow(@container).to receive(:using_lifetime).and_return(@container)
      allow(@container).to receive(:bound_to)
    end

    context 'in common case' do
      it 'register all loaded types in container using lifetime "scope" and bound to the request' do
        expect(@type_loader).to receive(:load_types)
        expect(@container).to receive(:register).with(@type1)
        expect(@container).to receive(:register).with(@type2)
        expect(@container).to receive(:using_lifetime).with(:scope).twice
        expect(@container).to receive(:bound_to).with(:silicon_request).twice

        dependency_loader = Silicon::DependencyLoader.new(@container, @type_loader, @silicon_env)
        dependency_loader.load_components
      end
    end

    context 'when silicon_env is development' do
      before :all do
        @silicon_env = 'development'
      end

      it 'every time loads types' do
        dependency_loader = Silicon::DependencyLoader.new(@container, @type_loader, @silicon_env)
        expect(@type_loader).to receive(:load_types).twice

        dependency_loader.load_components
        dependency_loader.load_components
      end
    end

    context 'when silicon_env is not development' do
      before :all do
        @silicon_env = 'production'
      end


      it 'skips loading types' do
        dependency_loader = Silicon::DependencyLoader.new(@container, @type_loader, @silicon_env)
        expect(@type_loader).not_to receive(:load_types)

        dependency_loader.load_components
      end
    end


  end
end
