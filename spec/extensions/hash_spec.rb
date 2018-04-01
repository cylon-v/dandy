require 'spec_helper'
require 'dandy/extensions/hash'

RSpec.describe Hash do
  describe 'symbolize_keys' do
    it 'symbolizes keys in hash' do
      hash = {
        'key1' => 'value1',
        'key2' => 'value2'
      }

      expect(hash.symbolize_keys).to eql({key1: 'value1', key2: 'value2'})
    end
  end

  describe 'deep_symbolize_keys!' do
    it 'symbolizes nested keys in hash' do
      hash = {
        'key1' => 'value1',
        'key2' => {
          'key3' => 'value3'
        }
      }

      expect(hash.deep_symbolize_keys!).to eql({key1: 'value1', key2: {key3: 'value3'}})
    end
  end
end
