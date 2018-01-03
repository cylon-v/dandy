require 'spec_helper'
require 'hypo'
require 'silicon/loaders/type_loader'
require 'silicon/loaders/dependency_loader'
require 'silicon/loaders/template_loader'
require 'silicon/config'
require 'silicon/request'
require 'silicon/template_registry'
require 'silicon/view_builder_registry'
require 'silicon/view_factory'
require 'silicon/chain_factory'
require 'silicon/view_builders/json'
require 'silicon/routing/routing'
require 'silicon/app'

RSpec.describe Silicon::App do
  before :each do
    @container = double(:container)
    @component = double(:component)

    allow(@container).to receive(:register_instance).and_return(@component)
    allow(@component).to receive(:using_lifetime)

    @chain_factory = double(:chain_factory)
    @view_factory = double(:view_factory)

    @view_builder_registry = double(:view_builder_registry)
    allow(@view_builder_registry).to receive(:add)

    @dependency_loader = double(:dependency_loader)
    allow(@dependency_loader).to receive(:load_components)

    @route_parser = double(:route_parser)
    allow(@route_parser).to receive(:parse).and_return([])

    allow(@container).to receive(:resolve).with(:chain_factory).and_return(@chain_factory)
    allow(@container).to receive(:resolve).with(:view_factory).and_return(@view_factory)
    allow(@container).to receive(:resolve).with(:dependency_loader).and_return(@dependency_loader)
    allow(@container).to receive(:resolve).with(:view_builder_registry).and_return(@view_builder_registry)
    allow(@container).to receive(:resolve).with(:route_parser).and_return(@route_parser)
  end

  describe 'initialize' do
    it 'registers required dependencies' do
      expect(@container).to receive(:register_instance).with('silicon.yaml', :config_file_path)

      expect(@container).to receive(:register).with(Silicon::Config, :silicon_config).and_return(@component)
      expect(@component).to receive(:using_lifetime).with(:singleton)

      expect(@container).to receive(:register).with(Silicon::TypeLoader, :type_loader).and_return(@component)
      expect(@component).to receive(:using_lifetime).with(:singleton)

      expect(@container).to receive(:register).with(Silicon::DependencyLoader, :dependency_loader).and_return(@component)
      expect(@component).to receive(:using_lifetime).with(:singleton)

      expect(@container).to receive(:register).with(Silicon::TemplateLoader, :template_loader).and_return(@component)
      expect(@component).to receive(:using_lifetime).with(:singleton)

      expect(@container).to receive(:register).with(Silicon::TemplateRegistry, :template_registry).and_return(@component)
      expect(@component).to receive(:using_lifetime).with(:singleton)

      expect(@container).to receive(:register).with(Silicon::ViewBuilderRegistry, :view_builder_registry).and_return(@component)
      expect(@component).to receive(:using_lifetime).with(:singleton)

      expect(@container).to receive(:register).with(Silicon::ViewFactory, :view_factory).and_return(@component)
      expect(@component).to receive(:using_lifetime).with(:singleton)

      expect(@container).to receive(:register).with(Silicon::ChainFactory, :chain_factory).and_return(@component)
      expect(@component).to receive(:using_lifetime).with(:singleton)

      expect(@container).to receive(:register).with(Silicon::Routing::FileReader, :file_reader).and_return(@component)
      expect(@component).to receive(:using_lifetime).with(:singleton)

      expect(@container).to receive(:register).with(SyntaxParser, :syntax_parser).and_return(@component)
      expect(@component).to receive(:using_lifetime).with(:singleton)

      expect(@container).to receive(:register).with(Silicon::Routing::SyntaxErrorInterpreter, :syntax_error_interpreter).and_return(@component)
      expect(@component).to receive(:using_lifetime).with(:singleton)

      expect(@container).to receive(:register).with(Silicon::Routing::Builder, :routes_builder).and_return(@component)
      expect(@component).to receive(:using_lifetime).with(:singleton)

      expect(@container).to receive(:register).with(Silicon::Routing::Parser, :route_parser).and_return(@component)
      expect(@component).to receive(:using_lifetime).with(:singleton)

      Silicon::App.new(@container)
    end

    it 'registers default Json view builder' do
      allow(@container).to receive(:register).and_return(@component)
      allow(@component).to receive(:using_lifetime).with(:singleton)

      expect(@view_builder_registry).to receive(:add).with(Silicon::ViewBuilders::Json, 'json')

      Silicon::App.new(@container)
    end
  end

  describe 'call' do
    it 'executes a request' do
      allow(@container).to receive(:register).and_return(@component)
      allow(@component).to receive(:using_lifetime).with(:singleton)
      allow(@view_builder_registry).to receive(:add)

      request = double(:request)
      route_matcher = double(:route_matcher)
      env = double(:env)

      app = Silicon::App.new(@container)
      app.instance_variable_set('@route_matcher', route_matcher)

      expect(Silicon::Request).to receive(:new).with(route_matcher, @container, @chain_factory, @view_factory).and_return(request)
      expect(request).to receive(:handle).with(env)
      app.call(env)
    end
  end
end
