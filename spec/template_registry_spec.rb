require 'spec_helper'
require 'dandy/template_registry'

RSpec.describe Dandy::TemplateRegistry do
  before :each do
    templates = {
      "views/view1.json" => "template 1",
      "views/view.json" => "template 2",
    }
    @template_loader = double(:template_loader)
    allow(@template_loader).to receive(:load_templates).and_return(templates)

    @dandy_config = {
      path: {
        views: '/views/'
      }
    }
  end

  describe 'get' do
    context 'in common case' do
      before :each do
        dandy_env = 'production'
        @template_registry = Dandy::TemplateRegistry.new(@template_loader, @dandy_config, dandy_env)
      end

      context 'when name does not match' do
        it 'raises specific exception' do
          expect {@template_registry.get('super-view', 'json')}
            .to raise_error(Dandy::DandyError, 'View "super-view" of type "json" not found')
        end
      end

      context 'when format does not match' do
        it 'raises specific exception' do
          expect {@template_registry.get('view1', 'xml')}
            .to raise_error(Dandy::DandyError, 'View "view1" of type "xml" not found')
        end
      end

      context 'when match found' do
        it 'returns view template content' do
          expect(@template_registry.get('view', 'json')).to eql('template 2')
        end
      end
    end

    context 'when dandy_env is development' do
      before :each do
        dandy_env = 'development'
        @template_registry = Dandy::TemplateRegistry.new(@template_loader, @dandy_config, dandy_env)
      end

      it 'every time reloads templates' do
        expect(@template_loader).to receive(:load_templates).twice
        @template_registry.get('view', 'json')
        @template_registry.get('view', 'json')
      end
    end

    context 'when dandy_env is not development' do
      before :each do
        dandy_env = 'production'
        @template_registry = Dandy::TemplateRegistry.new(@template_loader, @dandy_config, dandy_env)
      end

      it 'does not reload templates' do
        expect(@template_loader).not_to receive(:load_templates)
        @template_registry.get('view', 'json')
      end
    end
  end
end