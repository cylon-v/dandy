require 'dandy/view_builder'

module Dandy
  class ViewBuilderRegistry
    def initialize
      @view_builders = {}
    end

    def add(view_builder, format)
      unless view_builder < Dandy::ViewBuilder
        raise Dandy::DandyError, 'view_builder parameter should be a Dandy::ViewBuilder'
      end

      @view_builders[format] = view_builder
    end

    def get(format)
      @view_builders[format]
    end
  end
end