module Dandy
  class DependencyLoader
    def initialize(container, type_loader, dandy_env)
      @container = container
      @type_loader = type_loader
      @types = type_loader.load_types
      @dandy_env = dandy_env
    end

    def load_components(scope = :dandy_request)
      if @dandy_env == 'development'
        # every time reload types in development mode
        @types = @type_loader.load_types
      end

      @types.each do |type|
        @container.register(type[:class], type[:path].to_sym)
                  .using_lifetime(:scope)
                  .bound_to(scope)
      end
    end
  end
end