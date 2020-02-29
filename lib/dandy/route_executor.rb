require 'dandy/response'

module Dandy
  class RouteExecutor
    def initialize(container, dandy_config, view_factory)
      @container = container
      @dandy_config = dandy_config
      @view_factory = view_factory
    end

    def execute(route, headers)
      chain = Chain.new(@container, @dandy_config)

      begin
        result = chain.run_commands(route.commands, route.last_command)
        if route.view
          result = @view_factory.create(route.view, headers['Accept'], {keys_format: headers['Keys-Format'] || 'snake'})
        end

        body = result.is_a?(String) ? result : Response.format(result, headers)
      rescue Exception => error
        p error
        body = handle_error(route, headers, error)
      end

      body
    end

    private
    def handle_error(route, headers, error)
      @container
        .register_instance(error, :dandy_error)
        .using_lifetime(:scope)
        .bound_to(:dandy_request)

      action = @container.resolve(route.catch.name.to_sym)
      Response.format(action.call, headers)
    end
  end
end