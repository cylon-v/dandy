require 'hypo'
require 'json'
require 'rack/parser'
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
require 'dandy/route_executor'

module Dandy
  class App
    attr_reader :routes

    def initialize(container = Hypo::Container.new)
      @container = container

      register_dependencies
      load_basic_dependencies
      parse_entrypoints
      add_view_builders
    end

    def call(env)
      request = Request.new(@route_matcher, @container, @route_executor)
      request.handle(env)
    end

    protected

    def add_view_builder(view_builder, format)
      @view_builder_registry.add(view_builder, format)
    end

    private

    def add_view_builders
      add_view_builder(ViewBuilders::Json, 'json')
    end

    def register_dependencies
      instances = {
        config_file_path: 'dandy.yml',
        dandy_env: ENV['DANDY_ENV'] || 'development',
        env: ENV
      }

      instances.keys.each do |name|
        @container.register_instance(instances[name], name)
      end

      singletons = {
        dandy_config: Config,
        type_loader: TypeLoader,
        dependency_loader: DependencyLoader,
        template_loader: TemplateLoader,
        template_registry: TemplateRegistry,
        view_builder_registry: ViewBuilderRegistry,
        view_factory: ViewFactory,
        file_reader: Routing::FileReader,
        syntax_parser: SyntaxParser,
        syntax_error_interpreter: Routing::SyntaxErrorInterpreter,
        routes_builder: Routing::RoutesBuilder,
        handlers_builder: Routing::HandlersBuilder,
        dandy_parser: Routing::Parser,
        route_executor: RouteExecutor
      }

      singletons.keys.each do |name|
        @container.register(singletons[name], name)
          .using_lifetime(:singleton)
      end
    end

    def load_basic_dependencies
      @dandy_config = @container.resolve(:dandy_config)
      @view_factory = @container.resolve(:view_factory)
      @dependency_loader = @container.resolve(:dependency_loader)
      @view_builder_registry = @container.resolve(:view_builder_registry)
      @dandy_parser = @container.resolve(:dandy_parser)
      @route_executor = @container.resolve(:route_executor)

      @dependency_loader.load_components
    end

    def parse_entrypoints
      entrypoints = @dandy_parser.parse

      p entrypoints
      @routes = entrypoints[:routes]
      @message_handlers = entrypoints[:message_handlers]
      @route_matcher = Routing::Matcher.new(@routes)
    end
  end
end
