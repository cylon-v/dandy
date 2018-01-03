require 'silicon/chain'

module Silicon
  class ChainFactory
    def initialize(container, silicon_config)
      @container = container
      @silicon_config = silicon_config
    end

    def create(match)
      status = match.route.http_status || default_http_status(match.route.http_verb)
      register_params(match.params)
      register_status(status)
      Chain.new(@container, @silicon_config, match.route.commands, match.route.catch)
    end

    private

    def register_params(params)
      params.keys.each do |key|
        @container
          .register_instance(params[key], key.to_sym)
          .using_lifetime(:scope)
          .bound_to(:silicon_request)
      end
    end

    def register_status(status)
      @container
        .register_instance(status, :silicon_status)
        .using_lifetime(:scope)
        .bound_to(:silicon_request)
    end

    def default_http_status(http_verb)
      http_verb == 'POST' ? 201 : 200
    end
  end
end