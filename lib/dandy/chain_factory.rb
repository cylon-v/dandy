require 'dandy/chain'

module Dandy
  class ChainFactory
    def initialize(container, dandy_config)
      @container = container
      @dandy_config = dandy_config
    end

    def create(match)
      status = match.route.http_status || default_http_status(match.route.http_verb)
      register_params(match.params)
      register_status(status)
      Chain.new(@container, @dandy_config, match.route.commands, match.route.last_command, match.route.catch)
    end

    private

    def register_params(params)
      params.keys.each do |key|
        @container
          .register_instance(params[key], key.to_sym)
          .using_lifetime(:scope)
          .bound_to(:dandy_request)
      end
    end

    def register_status(status)
      @container
        .register_instance(status, :dandy_status)
        .using_lifetime(:scope)
        .bound_to(:dandy_request)
    end

    def default_http_status(http_verb)
      http_verb == 'POST' ? 201 : 200
    end
  end
end