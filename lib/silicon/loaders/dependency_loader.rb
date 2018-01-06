module Silicon
  class DependencyLoader
    def initialize(container, type_loader, silicon_env)
      @container = container
      @type_loader = type_loader
      @types = type_loader.load_types
      @silicon_env = silicon_env
    end

    def load_components
      if @silicon_env == 'development'
        # every time reload types in development mode
        @types = @type_loader.load_types
      end

      @types.each do |type|
        @container.register(type).using_lifetime(:scope).bound_to(:silicon_request)
      end
    end
  end
end