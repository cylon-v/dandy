require 'dandy/errors/dandy_error'

module Dandy
  class TemplateRegistry
    def initialize(template_loader, dandy_config, dandy_env)
      @template_loader = template_loader
      @templates = template_loader.load_templates
      @config = dandy_config
      @dandy_env = dandy_env
    end

    def get(name, type)
      if @dandy_env == 'development'
        # every time reload templates in development mode
        @templates = @template_loader.load_templates
      end

      directory = @config[:path][:views]
                    .sub(/^\//, '').sub(/(\/)+$/,'') # remove slash from start and end of the path

      regex = /#{Regexp.escape(directory)}\/.*#{Regexp.escape(name)}\.#{Regexp.escape(type)}/
      match = @templates.keys.find{|k| k.match(regex)}

      raise Dandy::DandyError, "View \"#{name}\" of type \"#{type}\" not found" if match.nil?

      @templates[match]
    end
  end
end