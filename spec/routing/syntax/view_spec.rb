require 'spec_helper'
require 'silicon/routing/syntax/view'

RSpec.describe Syntax::View do
  describe 'parse' do
    it 'returns correct text_value' do
      view = Syntax::View.new('some-text', 2)
      allow(view).to receive(:text_value).and_return('<*view_name')

      expect(view.parse).to eql('view_name')
    end
  end
end

