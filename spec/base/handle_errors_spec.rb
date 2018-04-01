require 'dandy/base/handle_errors'

class HandleErrors < Dandy::HandleErrors
  def call
    set_http_status 500
  end
end

RSpec.describe Dandy::HandleErrors do
  describe 'set_http_status' do
    it 'registers new http status in container with scoped lifetime' do
      component = double(:component)
      allow(component).to receive('using_lifetime').and_return(component)
      allow(component).to receive('bound_to').and_return(component)

      container = double(:container)
      allow(container).to receive('register_instance').and_return(component)

      expect(container).to receive(:register_instance).with(500, :dandy_status)
      expect(component).to receive(:using_lifetime).with(:scope)
      expect(component).to receive(:bound_to).with(:dandy_request)

      action = HandleErrors.new(container, nil)
      action.call
    end
  end
end
