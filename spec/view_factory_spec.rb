require 'spec_helper'
require 'dandy/view_factory'

RSpec.describe Dandy::ViewFactory do
  describe 'create' do
    let(:builder) { double(:builder) }
    let(:container) { double(:container) }
    let(:template) { double(:template) }
    let(:view) { double(:view) }
    let(:template_registry) { double(:template_registry) }
    let(:view_builder_registry) { double(:view_builder_registry) }
    let(:view_name) { 'view_name' }

    before :each do
      allow(view).to receive(:process)
      allow(template_registry).to receive(:get).with(view_name, 'json').and_return(template)
      allow(builder).to receive(:new).with(template, container, {}).and_return(view)
      allow(view_builder_registry).to receive(:get).with('json').and_return(builder)
    end

    context 'when builder is defined' do
      it 'creates a view using ' do
        view_factory = Dandy::ViewFactory.new(container, template_registry, view_builder_registry)
        expect(view).to receive(:process)
        view_factory.create(view_name,  'application/json')
      end
    end

    context 'when builder for the content-type is not defined' do
      before :each do
        allow(builder).to receive(:new).with(template, container, {}).and_return(view)
        allow(view_builder_registry).to receive(:get).with('html').and_return(nil)
        allow(view_builder_registry).to receive(:get).with('json').and_return(builder)
      end

      it 'creates a view using json builder' do
        view_factory = Dandy::ViewFactory.new(container, template_registry, view_builder_registry)
        expect(view).to receive(:process)
        view_factory.create(view_name,  'text/html')
      end
    end
  end
end

