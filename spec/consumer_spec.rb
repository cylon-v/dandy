require 'spec_helper'
require 'dandy/consumer'

RSpec.describe Dandy::Consumer do
  let(:consumer) { Dandy::Consumer.new }
  let(:handler) { double(:handler) }
  let(:message_handlers) { [handler] }
  let(:message) { 'some.message' }
  let(:handler_executor) { double(:handler_executor) }

  before :each do
    allow(handler).to receive(:name).and_return(message)
  end
  
  it 'correctly connects and handle messages' do
    expect(handler_executor).to receive(:execute).with(handler)
    consumer.connect(message_handlers, handler_executor)
    consumer.handle(message)
  end
end