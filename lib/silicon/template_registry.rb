module Silicon
  class TemplateRegistry
    def initialize(template_loader, silicon_config, silicon_env)
      @template_loader = template_loader
      @templates = template_loader.load_templates
      @config = silicon_config
      @silicon_env = silicon_env
    end

    def get(name, type)
      if @silicon_env == 'development'
        # every time reload templates in development mode
        @templates = @template_loader.load_templates
      end

      directory = @config[:path][:views]
      regex = /#{Regexp.escape(directory)}\/.*#{Regexp.escape(name)}\.#{Regexp.escape(type)}/
      match = @templates.keys.find{|k| k.match(regex)}
      raise Silicon::SiliconError, "View #{name} of type #{type} not found" if match.nil?

      @templates[match]
    end
  end
end