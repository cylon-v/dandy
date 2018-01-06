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

    @silicon_config = {
      path: {
        views: 'silicon/views/'
      }
    }
  end

  describe 'get' do
    context 'in common case' do
      before :each do
        silicon_env = 'production'
        @template_registry = Silicon::TemplateRegistry.new(@template_loader, @silicon_config, silicon_env)
      end

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

    context 'when silicon_env is development' do
      before :each do
        silicon_env = 'development'
        @template_registry = Silicon::TemplateRegistry.new(@template_loader, @silicon_config, silicon_env)
      end

      it 'every time reloads templates' do
        expect(@template_loader).to receive(:load_templates).twice
        @template_registry.get('view', 'json')
        @template_registry.get('view', 'json')
      end
    end

    context 'when silicon_env is not development' do
      before :each do
        silicon_env = 'production'
        @template_registry = Silicon::TemplateRegistry.new(@template_loader, @silicon_config, silicon_env)
      end

      it 'does not reload templates' do
        expect(@template_loader).not_to receive(:load_templates)
        @template_registry.get('view', 'json')
      end
    end
  end
end