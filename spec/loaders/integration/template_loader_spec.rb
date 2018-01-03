require 'spec_helper'
require 'silicon/loaders/template_loader'

RSpec.describe Silicon::TemplateLoader do
  describe '[Integration] load_templates' do
    it 'loads view templates from file system' do
      silicon_config = {
        path: {
          views: ['spec/loaders/integration/samples/views']
        }
      }

      template_loader = Silicon::TemplateLoader.new(silicon_config)

      expected = {
        'spec/loaders/integration/samples/views/test1.txt' => 'test1',
        'spec/loaders/integration/samples/views/test2.json' => '{"test2": "json"}',
      }
      expect(template_loader.load_templates).to eql(expected)
    end
  end
end
