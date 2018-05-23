module Dandy
  class SafeExecutor
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

        body = result.is_a?(String) ? result : format_response(result, headers)
      rescue Exception => error
        @container
          .register_instance(error, :dandy_error)
          .using_lifetime(:scope)
          .bound_to(:dandy_request)

        action = @container.resolve(route.catch.name.to_sym)
        body = format_response(action.call, headers)
      end

      body
    end

    private
    def format_response(result, headers)
      if headers['Keys-Format'] == 'camel' && result
        result = result.to_camelback_keys
      end

      JSON.generate(result)
    end
  end
end