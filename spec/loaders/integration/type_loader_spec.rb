require 'spec_helper'
require 'silicon/loaders/type_loader'

RSpec.describe Silicon::TypeLoader do
  describe '[Integration] load_types' do
    it 'loads types from file system' do
      silicon_config = {
        path: {
          dependencies: ['spec/loaders/integration/samples/types']
        }
      }

      type_loader = Silicon::TypeLoader.new(silicon_config)
      expect(type_loader.load_types).to eql [Type1, Type2]
    end
  end
end
