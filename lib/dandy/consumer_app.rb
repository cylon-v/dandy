require 'hypo'
require 'dandy/loaders/type_loader'
require 'dandy/loaders/dependency_loader'
require 'dandy/config'
require 'dandy/handler_executor'

module Dandy
  class ConsumerApp
    def initialize(container = Hypo::Container.new)
      @container = container

      register_dependencies
      load_basic_dependencies
      parse_entrypoints
    end

    protected

    def add_consumer(consumer)
      consumer.connect(@message_handlers, @handler_executor)
    end

    private

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
        file_reader: Routing::FileReader,
        syntax_parser: SyntaxParser,
        syntax_error_interpreter: Routing::SyntaxErrorInterpreter,
        handlers_builder: Routing::HandlersBuilder,
        dandy_parser: Routing::HandlerParser,
        handler_executor: HandlerExecutor
      }

      singletons.keys.each do |name|
        @container.register(singletons[name], name)
          .using_lifetime(:singleton)
      end
    end

    def load_basic_dependencies
      @dandy_config = @container.resolve(:dandy_config)
      @dependency_loader = @container.resolve(:dependency_loader)
      @dandy_parser = @container.resolve(:dandy_parser)
      @handler_executor = @container.resolve(:handler_executor)

      @dependency_loader.load_components(:dandy_message)
    end

    def parse_entrypoints
      entrypoints = @dandy_parser.parse
      @message_handlers = entrypoints[:message_handlers]
    end
  end
end
