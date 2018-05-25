require 'spec_helper'
require 'hypo'
require 'dandy/loaders/type_loader'
require 'dandy/loaders/dependency_loader'
require 'dandy/loaders/template_loader'
require 'dandy/config'
require 'dandy/request'
require 'dandy/template_registry'
require 'dandy/view_builder_registry'
require 'dandy/view_factory'
require 'dandy/view_builders/json'
require 'dandy/routing/routing'
require 'dandy/app'

RSpec.describe Dandy::App do
  before :each do
    @container = double(:container)
    @component = double(:component)

    allow(@container).to receive(:register_instance).and_return(@component)
    allow(@component).to receive(:using_lifetime)

    @dandy_config = double(:dandy_config)
    @view_factory = double(:view_factory)
    @safe_executor = double(:safe_executor)

    @view_builder_registry = double(:view_builder_registry)
    allow(@view_builder_registry).to receive(:add)

    @dependency_loader = double(:dependency_loader)
    allow(@dependency_loader).to receive(:load_components)

    @route_parser = double(:route_parser)
    allow(@route_parser).to receive(:parse).and_return([])

    allow(@container).to receive(:resolve).with(:dandy_config).and_return(@dandy_config)
    allow(@container).to receive(:resolve).with(:view_factory).and_return(@view_factory)
    allow(@container).to receive(:resolve).with(:dependency_loader).and_return(@dependency_loader)
    allow(@container).to receive(:resolve).with(:view_builder_registry).and_return(@view_builder_registry)
    allow(@container).to receive(:resolve).with(:route_parser).and_return(@route_parser)
    allow(@container).to receive(:resolve).with(:safe_executor).and_return(@safe_executor)
  end

  describe 'initialize' do
    it 'registers required dependencies' do
      expect(@container).to receive(:register_instance).with('development', :dandy_env)
      expect(@container).to receive(:register_instance).with('dandy.yml', :config_file_path)

      expect(@container).to receive(:register).with(Dandy::Config, :dandy_config).and_return(@component)
      expect(@component).to receive(:using_lifetime).with(:singleton)

      expect(@container).to receive(:register).with(Dandy::TypeLoader, :type_loader).and_return(@component)
      expect(@component).to receive(:using_lifetime).with(:singleton)

      expect(@container).to receive(:register).with(Dandy::DependencyLoader, :dependency_loader).and_return(@component)
      expect(@component).to receive(:using_lifetime).with(:singleton)

      expect(@container).to receive(:register).with(Dandy::TemplateLoader, :template_loader).and_return(@component)
      expect(@component).to receive(:using_lifetime).with(:singleton)

      expect(@container).to receive(:register).with(Dandy::TemplateRegistry, :template_registry).and_return(@component)
      expect(@component).to receive(:using_lifetime).with(:singleton)

      expect(@container).to receive(:register).with(Dandy::ViewBuilderRegistry, :view_builder_registry).and_return(@component)
      expect(@component).to receive(:using_lifetime).with(:singleton)

      expect(@container).to receive(:register).with(Dandy::ViewFactory, :view_factory).and_return(@component)
      expect(@component).to receive(:using_lifetime).with(:singleton)

      expect(@container).to receive(:register).with(Dandy::Routing::FileReader, :file_reader).and_return(@component)
      expect(@component).to receive(:using_lifetime).with(:singleton)

      expect(@container).to receive(:register).with(SyntaxParser, :syntax_parser).and_return(@component)
      expect(@component).to receive(:using_lifetime).with(:singleton)

      expect(@container).to receive(:register).with(Dandy::Routing::SyntaxErrorInterpreter, :syntax_error_interpreter).and_return(@component)
      expect(@component).to receive(:using_lifetime).with(:singleton)

      expect(@container).to receive(:register).with(Dandy::Routing::Builder, :routes_builder).and_return(@component)
      expect(@component).to receive(:using_lifetime).with(:singleton)

      expect(@container).to receive(:register).with(Dandy::Routing::Parser, :route_parser).and_return(@component)
      expect(@component).to receive(:using_lifetime).with(:singleton)

      expect(@container).to receive(:register).with(Dandy::SafeExecutor, :safe_executor).and_return(@component)
      expect(@component).to receive(:using_lifetime).with(:singleton)

      Dandy::App.new(@container)
    end

    it 'registers default Json view builder' do
      allow(@container).to receive(:register).and_return(@component)
      allow(@component).to receive(:using_lifetime).with(:singleton)

      expect(@view_builder_registry).to receive(:add).with(Dandy::ViewBuilders::Json, 'json')

      Dandy::App.new(@container)
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

      app = Dandy::App.new(@container)
      app.instance_variable_set('@route_matcher', route_matcher)

      expect(Dandy::Request).to receive(:new).with(route_matcher, @container, @safe_executor).and_return(request)
      expect(request).to receive(:handle).with(env)
      app.call(env)
    end
  end
end
