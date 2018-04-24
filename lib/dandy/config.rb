require 'yaml'
require 'erb'
require 'dandy/extensions/hash'

module Dandy
  class Config
    def initialize(config_file_path)
      path = File.join(Dir.pwd, config_file_path)
      yaml = ERB.new(File.read(path)).result
      @params = YAML.load(yaml).deep_symbolize_keys!
    end

    def [](key)
      @params[key]
    end
  end
end