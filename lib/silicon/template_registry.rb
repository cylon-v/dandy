module Silicon
  class TemplateRegistry
    def initialize(template_loader, silicon_config)
      @templates = template_loader.load_templates
      @config = silicon_config
    end

    def get(name, type)
      directory = @config[:path][:views]
      template_path = File.join(directory, name + ".#{type}")
      match = @templates.keys.find{|k| k.include? template_path}
      raise Silicon::SiliconError, "View #{name} of type #{type} not found" if match.nil?

      @templates[match]
    end
  end
end