require 'spec_helper'
require 'dandy/loaders/type_loader'

RSpec.describe Dandy::TypeLoader do
  describe '[Integration] load_types' do
    it 'loads types from file system' do
      dandy_config = {
        path: {
          dependencies: ['spec/loaders/integration/samples/types']
        }
      }

      type_loader = Dandy::TypeLoader.new(dandy_config)
      expect(type_loader.load_types).to contain_exactly({
        class: Type1,
        path: 'path/to/type1'
      },{
        class: Type2,
        path: 'type2'
      })
    end
  end
end
