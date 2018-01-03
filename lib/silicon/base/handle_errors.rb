module Silicon
  class HandleErrors
    def initialize(container, silicon_error)
      @container = container
      @silicon_error = silicon_error
    end

    protected
    def set_http_status(status_code)
      @container
        .register_instance(status_code, :silicon_status)
        .using_lifetime(:scope)
        .bound_to(:silicon_request)
    end
  end
end