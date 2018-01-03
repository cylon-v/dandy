require 'silicon/view_builder'

module Silicon
  class ViewBuilderRegistry
    def initialize
      @view_builders = {}
    end

    def add(view_builder, format)
      unless view_builder < Silicon::ViewBuilder
        raise Silicon::SiliconError, 'view_builder parameter should be a Silicon::ViewBuilder'
      end

      @view_builders[format] = view_builder
    end

    def get(format)
      @view_builders[format]
    end
  end
end