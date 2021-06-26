require 'spec_helper'
require 'dandy/consumer'

RSpec.describe Dandy::Consumer do
  let(:container) { Hypo::Container.new}
  let(:consumer) { Dandy::Consumer.new(container) }
  let(:handler) { double(:handler) }
  let(:message_handlers) { [handler] }
  let(:message_name) { 'some.message' }
  let(:message_payload) { 'some.payload' }
  let(:handler_executor) { double(:handler_executor) }

  before :each do
    allow(consumer).to receive(:subscribe)
    allow(handler).to receive(:name).and_return(message_name)
  end
  
  it 'correctly connects and handle messages' do
    expect(handler_executor).to receive(:execute).with(handler)
    consumer.connect(message_handlers, handler_executor)
    consumer.handle(message_name, message_payload)
  end
end