require 'spec_helper'
require 'silicon/routing/syntax/before_section'
require 'silicon/routing/syntax/commands'

RSpec.describe Syntax::BeforeSection do
  describe 'parse' do
    before :each do
      @before_section = Syntax::BeforeSection.new('some-text', 2)
    end

    context 'when does not contain command elements' do
      before :each do
        allow(@before_section).to receive(:elements).and_return([])
      end

      it 'does not add commands to the section' do
        @before_section.parse
        expect(@before_section.commands).to eql([])
      end
    end

    context 'when contains command elements' do
      before :each do
        commands_element = Syntax::Commands.new('some-text', 2)
        allow(commands_element).to receive(:parse).and_return(['command'])

        level2 = double(:level2)
        allow(level2).to receive(:elements).and_return([commands_element])

        allow(@before_section).to receive(:elements).and_return([level2])
      end

      it 'adds commands to the section' do
        @before_section.parse
        expect(@before_section.commands).to eql(['command'])
      end
    end
  end
end
