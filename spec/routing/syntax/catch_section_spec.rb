require 'spec_helper'
require 'silicon/routing/syntax/catch_section'
require 'silicon/routing/syntax/command'

RSpec.describe Syntax::CatchSection do
  describe 'parse' do
    before :each do
      @catch_section = Syntax::CatchSection.new('some-text', 2)
    end

    context 'when does not contain command element' do
      before :each do
        level2 = double(:level2)
        allow(level2).to receive(:elements).and_return([])

        allow(@catch_section).to receive(:elements).and_return([level2])
      end

      it 'does not add commands to the section' do
        @catch_section.parse
        expect(@catch_section.command).to eql(nil)
      end
    end

    context 'when contains command element' do
      before :each do
        command_element = Syntax::Command.new('some-text', 2)
        allow(command_element).to receive(:parse).and_return('command')

        level2 = double(:level2)
        allow(level2).to receive(:elements).and_return([command_element])

        allow(@catch_section).to receive(:elements).and_return([level2])
      end

      it 'adds commands to the section' do
        @catch_section.parse
        expect(@catch_section.command).to eql('command')
      end
    end
  end
end
