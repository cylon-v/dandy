module Silicon
  class DependencyLoader
    def initialize(container, type_loader)
      @container = container
      @types = type_loader.load_types
    end

    def load_components
      @types.each do |type|
        @container.register(type).using_lifetime(:scope).bound_to(:silicon_request)
      end
    end
  end
end