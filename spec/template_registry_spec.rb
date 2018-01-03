require 'spec_helper'
require 'silicon/template_registry'

RSpec.describe Silicon::TemplateRegistry do
  before :each do
    templates = {
      "silicon/views/view1.json" => "template 1",
      "silicon/views/view.json" => "template 2",
    }
    @template_loader = double(:template_loader)
    allow(@template_loader).to receive(:load_templates).and_return(templates)

    silicon_config = {
      path: {
        views: 'silicon/views/'
      }
    }
    @template_registry = Silicon::TemplateRegistry.new(@template_loader, silicon_config)
  end

  describe 'get' do
    context 'when name does not match' do
      it 'raises specific exception' do
        expect {@template_registry.get('super-view', 'json')}
          .to raise_error(Silicon::SiliconError, 'View super-view of type json not found')
      end
    end

    context 'when format does not match' do
      it 'raises specific exception' do
        expect {@template_registry.get('view1', 'xml')}
          .to raise_error(Silicon::SiliconError, 'View view1 of type xml not found')
      end
    end

    context 'when match found' do
      it 'returns view template content' do
        expect(@template_registry.get('view', 'json')).to eql('template 2')
      end
    end
  end
end