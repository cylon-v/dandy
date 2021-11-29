require 'spec_helper'
require 'dandy/loaders/dependency_loader'
require 'hypo'

RSpec.describe Dandy::DependencyLoader do
  describe 'load_components' do
    before :each do
      @container = double(:container)
      @type_loader = double(:type_loader)

      @type1 = double(:type1)
      @type2 = double(:type2)

      allow(@type_loader).to receive(:load_types).and_return([{
        class: @type1,
        path: 'path/to/type1'
      }, {
        class: @type2,
        path: 'type2'
      }])
      allow(@container).to receive(:register).and_return(@container)
      allow(@container).to receive(:using_lifetime).and_return(@container)
      allow(@container).to receive(:bound_to)
    end

    context 'in common case' do
      it 'register all loaded types in container using lifetime "scope" and bound to the request' do
        expect(@type_loader).to receive(:load_types)
        expect(@container).to receive(:register).with(@type1, :'path/to/type1')
        expect(@container).to receive(:register).with(@type2, :type2)
        expect(@container).to receive(:using_lifetime).with(:scope).twice
        expect(@container).to receive(:bound_to).with(:dandy_request).twice

        dependency_loader = described_class.new(@container, @type_loader, @dandy_env)
        dependency_loader.load_components(:dandy_request)
      end
    end

    context 'when dandy_env is development' do
      before :all do
        @dandy_env = 'development'
      end

      it 'every time loads types' do
        dependency_loader = Dandy::DependencyLoader.new(@container, @type_loader, @dandy_env)
        expect(@type_loader).to receive(:load_types).twice

        dependency_loader.load_components(:dandy_request)
        dependency_loader.load_components(:dandy_request)
      end
    end

    context 'when dandy_env is not development' do
      before :all do
        @dandy_env = 'production'
      end


      it 'skips loading types' do
        dependency_loader = Dandy::DependencyLoader.new(@container, @type_loader, @dandy_env)
        expect(@type_loader).not_to receive(:load_types)

        dependency_loader.load_components(:dandy_request)
      end
    end


  end
end
