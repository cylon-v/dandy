require 'spec_helper'
require 'silicon/routing/syntax/command'


RSpec.describe Syntax::Command do
  describe 'parse' do
    before :each do
      @command = Syntax::Command.new('some-text', 2)
    end

    it 'correctly parses the name' do
      allow(@command).to receive(:text_value).and_return('*>=*=>command_name')
      @command.parse

      expect(@command.name).to eql('command_name')
    end

    context 'when it\'s starts with =*' do
      before :each do
        allow(@command).to receive(:text_value).and_return('=*command_name')
        @command.parse
      end

      it 'should be identified as async' do
        expect(@command.async?).to eql(true)
        expect(@command.sequential?).to eql(false)
        expect(@command.parallel?).to eql(false)
      end
    end

    context 'when it\'s starts with *>' do
      before :each do
        allow(@command).to receive(:text_value).and_return('*>command_name')
        @command.parse
      end

      it 'should be identified as sequential' do
        expect(@command.async?).to eql(false)
        expect(@command.sequential?).to eql(true)
        expect(@command.parallel?).to eql(false)
      end
    end

    context 'when it\'s starts with =>' do
      before :each do
        allow(@command).to receive(:text_value).and_return('=>command_name')
        @command.parse
      end

      it 'should be identified as parallel' do
        expect(@command.async?).to eql(false)
        expect(@command.sequential?).to eql(false)
        expect(@command.parallel?).to eql(true)
      end
    end

    context 'it contains a result name (result_name@command)' do
      before :each do
        allow(@command).to receive(:text_value).and_return('=>result_name@command_name')
        @command.parse
      end

      it 'should parse name and result name' do
        expect(@command.name).to eql('command_name')
        expect(@command.result_name).to eql('result_name')
      end
    end
  end
end
