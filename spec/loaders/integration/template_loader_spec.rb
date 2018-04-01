require 'spec_helper'
require 'dandy/loaders/template_loader'

RSpec.describe Dandy::TemplateLoader do
  describe '[Integration] load_templates' do
    it 'loads view templates from file system' do
      dandy_config = {
        path: {
          views: ['spec/loaders/integration/samples/views/']
        }
      }

      template_loader = Dandy::TemplateLoader.new(dandy_config)

      expected = {
        'spec/loaders/integration/samples/views/test1.txt' => 'test1',
        'spec/loaders/integration/samples/views/test2.json' => '{"test2": "json"}',
      }
      expect(template_loader.load_templates).to eql(expected)
    end
  end
end
