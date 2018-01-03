require 'silicon/routing/routing'
require 'silicon/config'

RSpec.describe '[Integration] Syntax Parsing' do
  subject do
    syntax_parser = SyntaxParser.new
    routes_builder = Silicon::Routing::Builder.new
    config = Silicon::Config.new(@config_path)
    file_reader = Silicon::Routing::FileReader.new(config)

    syntax_error_detector = Silicon::Routing::SyntaxErrorInterpreter.new(syntax_parser)

    parser = Silicon::Routing::Parser.new(file_reader, routes_builder, syntax_parser, syntax_error_detector)
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