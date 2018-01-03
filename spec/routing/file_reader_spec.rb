require 'spec_helper'
require 'silicon/routing/file_reader'

RSpec.describe Silicon::Routing::FileReader do
  describe 'read' do
    it 'loads and prepares routes definition file' do
      initial_content = "/users -> \n\tGET -> action1\n  POST -> action2 -> :respond <- list_users \n"
      expected_content = '/users*>;^GET*>action1;^POST*>action2*>:respond<*list_users;;'

      allow(File).to receive(:join)
      allow(File).to receive(:read).and_return initial_content

      config = {path: {routes: 'app.routes'}}
      file_reader = Silicon::Routing::FileReader.new(config)
      expect(file_reader.read).to eql expected_content
    end
  end
end
