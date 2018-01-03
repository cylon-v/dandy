require 'spec_helper'
require 'silicon/routing/syntax/primitives/http_status'


RSpec.describe Syntax::HttpStatus do
  describe 'parse' do
    before :each do
      @respond = Syntax::HttpStatus.new('some-text', 2)
    end

    context 'when text_value is empty' do
      before :each do
        allow(@respond).to receive(:text_value).and_return('')
      end

      it 'returns nil' do
        expect(@respond.parse).to eql(nil)
      end
    end

    context 'when text_value has value' do
      before :each do
        allow(@respond).to receive(:text_value).and_return('=201')
      end

      it 'returns parsed status' do
        expect(@respond.parse).to eql(201)
      end
    end
  end
end
