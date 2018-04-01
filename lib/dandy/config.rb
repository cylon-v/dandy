require 'yaml'
require 'dandy/extensions/hash'

module Dandy
  class Config
    def initialize(config_file_path)
      path = File.join(Dir.pwd, config_file_path)
      @params = YAML.load_file(path).deep_symbolize_keys!
    end

    def [](key)
      @params[key]
    end
  end
end