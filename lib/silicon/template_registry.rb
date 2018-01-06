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
      template_path = File.join(directory, name + ".#{type}")
      match = @templates.keys.find{|k| k.include? template_path}
      raise Silicon::SiliconError, "View #{name} of type #{type} not found" if match.nil?

      @templates[match]
    end
  end
end