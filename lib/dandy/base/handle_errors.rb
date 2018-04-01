module Dandy
  class HandleErrors
    def initialize(container, dandy_error)
      @container = container
      @dandy_error = dandy_error
    end

    protected
    def set_http_status(status_code)
      @container
        .register_instance(status_code, :dandy_status)
        .using_lifetime(:scope)
        .bound_to(:dandy_request)
    end
  end
end