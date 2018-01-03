require 'spec_helper'
require 'silicon/view_factory'

RSpec.describe Silicon::ViewFactory do
  describe 'create' do
    it 'creates a view' do
      name = 'view_name'
      content_type = 'application/json'

      container = double(:container)
      template = double(:template)

      view = double(:view)
      allow(view).to receive(:process)

      builder = double(:builder)
      allow(builder).to receive(:new).with(template, container).and_return(view)

      template_registry = double(:template_registry)
      allow(template_registry).to receive(:get).with(name, 'json').and_return(template)

      view_builder_registry = double(:view_builder_registry)
      allow(view_builder_registry).to receive(:get).with('json').and_return(builder)

      view_factory = Silicon::ViewFactory.new(container, template_registry, view_builder_registry)

      expect(view).to receive(:process)
      view_factory.create(name,  'application/json')
    end
  end
end

