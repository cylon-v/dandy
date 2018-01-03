require 'spec_helper'
require 'silicon/routing/syntax/after_section'
require 'silicon/routing/syntax/commands'

RSpec.describe Syntax::AfterSection do
  describe 'parse' do
    before :each do
      @after_section = Syntax::AfterSection.new('some-text', 2)
    end

    context 'when does not contain command elements' do
      before :each do
        allow(@after_section).to receive(:elements).and_return([])
      end

      it 'does not add commands to the section' do
        @after_section.parse
        expect(@after_section.commands).to eql([])
      end
    end

    context 'when contains command elements' do
      before :each do
        commands_element = Syntax::Commands.new('some-text', 2)
        allow(commands_element).to receive(:parse).and_return(['command'])

        level2 = double(:level2)
        allow(level2).to receive(:elements).and_return([commands_element])

        allow(@after_section).to receive(:elements).and_return([level2])
      end

      it 'adds commands to the section' do
        @after_section.parse
        expect(@after_section.commands).to eql(['command'])
      end
    end
  end
end
