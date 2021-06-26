require 'dandy/routing/routing'
require 'dandy/config'

RSpec.describe '[Integration] Syntax Parsing' do
  subject do
    syntax_parser = SyntaxParser.new
    routes_builder = Dandy::Routing::RoutesBuilder.new
    handlers_builder = Dandy::Routing::HandlersBuilder.new
    config = Dandy::Config.new(@config_path)
    file_reader = Dandy::Routing::FileReader.new(config)

    syntax_error_detector = Dandy::Routing::SyntaxErrorInterpreter.new(syntax_parser)

    parser = Dandy::Routing::Parser.new(file_reader, routes_builder, handlers_builder, syntax_parser, syntax_error_detector)
    parser.parse
  end

  it 'all features test' do
    @config_path = 'spec/routing/integration/samples/all_features_config.yaml'
    subject
  end

  it 'simple flow test' do
    @config_path = 'spec/routing/integration/samples/simple_flow_config.yaml'
    subject
  end
end