require 'spec_helper'
require 'silicon/view_builder'

RSpec.describe Silicon::ViewBuilder do
  describe 'process' do
    before :each do
      template = '@name - powerful template engine.'

      container = double(:container)
      allow(container).to receive(:resolve).with(:name).and_return('my_engine')

      @view_builder = Silicon::ViewBuilder.new(template, container)
      allow(@view_builder).to receive(:build)
    end

    subject {@view_builder.process}

    it 'initializes template variables' do
      subject
      expect(@view_builder.instance_variable_get('@name')).to eql('my_engine')
    end

    it 'invokes "build" method implemented in derived class' do
      expect(@view_builder).to receive(:build)
      subject
    end
  end
end