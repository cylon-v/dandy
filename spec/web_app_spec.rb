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
require 'dandy/web_app'

RSpec.describe Dandy::WebApp do
  let(:container) { double(:container) }
  let(:component) { double(:component) }
  let(:dandy_config) { double(:dandy_config) }
  let(:view_factory) { double(:view_factory) }
  let(:route_executor) { double(:route_executor) }
  let(:handler_executor) { double(:handler_executor) }
  let(:view_builder_registry) { double(:view_builder_registry) }
  let(:dependency_loader) { double(:dependency_loader) }
  let(:dandy_parser) { double(:dandy_parser) }

  let :entrypoints do
    {routes: [], message_handlers: []}
  end

  before :each do
    allow(container).to receive(:register_instance).and_return(component)
    allow(component).to receive(:using_lifetime)
    allow(view_builder_registry).to receive(:add)
    allow(dependency_loader).to receive(:load_components)
    allow(dandy_parser).to receive(:parse).and_return(entrypoints)

    allow(container).to receive(:resolve).with(:dandy_config).and_return(dandy_config)
    allow(container).to receive(:resolve).with(:view_factory).and_return(view_factory)
    allow(container).to receive(:resolve).with(:dependency_loader).and_return(dependency_loader)
    allow(container).to receive(:resolve).with(:view_builder_registry).and_return(view_builder_registry)
    allow(container).to receive(:resolve).with(:dandy_parser).and_return(dandy_parser)
    allow(container).to receive(:resolve).with(:route_executor).and_return(route_executor)
    allow(container).to receive(:resolve).with(:handler_executor).and_return(handler_executor)
  end

  describe 'initialize' do
    it 'registers required dependencies' do
      expect(container).to receive(:register_instance).with('development', :dandy_env)
      expect(container).to receive(:register_instance).with('dandy.yml', :config_file_path)

      expect(container).to receive(:register).with(Dandy::Config, :dandy_config).and_return(component)
      expect(component).to receive(:using_lifetime).with(:singleton)

      expect(container).to receive(:register).with(Dandy::TypeLoader, :type_loader).and_return(component)
      expect(component).to receive(:using_lifetime).with(:singleton)

      expect(container).to receive(:register).with(Dandy::DependencyLoader, :dependency_loader).and_return(component)
      expect(component).to receive(:using_lifetime).with(:singleton)

      expect(container).to receive(:register).with(Dandy::TemplateLoader, :template_loader).and_return(component)
      expect(component).to receive(:using_lifetime).with(:singleton)

      expect(container).to receive(:register).with(Dandy::TemplateRegistry, :template_registry).and_return(component)
      expect(component).to receive(:using_lifetime).with(:singleton)

      expect(container).to receive(:register).with(Dandy::ViewBuilderRegistry, :view_builder_registry).and_return(component)
      expect(component).to receive(:using_lifetime).with(:singleton)

      expect(container).to receive(:register).with(Dandy::ViewFactory, :view_factory).and_return(component)
      expect(component).to receive(:using_lifetime).with(:singleton)

      expect(container).to receive(:register).with(Dandy::Routing::FileReader, :file_reader).and_return(component)
      expect(component).to receive(:using_lifetime).with(:singleton)

      expect(container).to receive(:register).with(SyntaxParser, :syntax_parser).and_return(component)
      expect(component).to receive(:using_lifetime).with(:singleton)

      expect(container).to receive(:register).with(Dandy::Routing::SyntaxErrorInterpreter, :syntax_error_interpreter).and_return(component)
      expect(component).to receive(:using_lifetime).with(:singleton)

      expect(container).to receive(:register).with(Dandy::Routing::RoutesBuilder, :routes_builder).and_return(component)
      expect(component).to receive(:using_lifetime).with(:singleton)

      expect(container).to receive(:register).with(Dandy::Routing::HandlersBuilder, :handlers_builder).and_return(component)
      expect(component).to receive(:using_lifetime).with(:singleton)

      expect(container).to receive(:register).with(Dandy::Routing::WebParser, :dandy_parser).and_return(component)
      expect(component).to receive(:using_lifetime).with(:singleton)

      expect(container).to receive(:register).with(Dandy::RouteExecutor, :route_executor).and_return(component)
      expect(component).to receive(:using_lifetime).with(:singleton)

      expect(container).to receive(:register).with(Dandy::HandlerExecutor, :handler_executor).and_return(component)
      expect(component).to receive(:using_lifetime).with(:singleton)

      described_class.new(container)
    end

    it 'registers default Json view builder' do
      allow(container).to receive(:register).and_return(component)
      allow(component).to receive(:using_lifetime).with(:singleton)

      expect(view_builder_registry).to receive(:add).with(Dandy::ViewBuilders::Json, 'json')

      described_class.new(container)
    end
  end

  describe 'call' do
    it 'executes a request' do
      allow(container).to receive(:register).and_return(component)
      allow(component).to receive(:using_lifetime).with(:singleton)
      allow(view_builder_registry).to receive(:add)

      request = double(:request)
      route_matcher = double(:route_matcher)
      env = double(:env)

      app = described_class.new(container)
      app.instance_variable_set('@route_matcher', route_matcher)

      expect(Dandy::Request).to receive(:new).with(route_matcher, container, route_executor).and_return(request)
      expect(request).to receive(:handle).with(env)
      app.call(env)
    end
  end
end
