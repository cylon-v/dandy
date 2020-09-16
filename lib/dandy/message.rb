require 'json'
require 'awrence'
require 'plissken'
require 'rack/multipart'
require 'dandy/extensions/hash'
require 'dandy/view_factory'
require 'dandy/chain'

module Dandy
  class Message
    include Hypo::Scope

    def initialize(container, handler, handler_executor)
      @container = container
      @handler = handler
      @handler_executor = handler_executor
    end

    def handle(data)
      create_scope
      register_data(data)

      begin
        result = @handler_executor.execute(@handler)
        release
      rescue Exception => error
        result = @handler_executor.handle_error(@handler, error)
      end

      result
    end

    private

    def create_scope
      @container
          .register_instance(self, :dandy_message)
          .using_lifetime(:scope)
          .bound_to(self)
    end

    def register_data(data)
      unless params.nil?
        @container.register_instance(data, :dandy_data)
            .using_lifetime(:scope)
            .bound_to(:dandy_request)
      end
    end
  end
end