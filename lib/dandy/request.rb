require 'json'
require 'dandy/extensions/hash'
require 'dandy/chain_factory'
require 'dandy/view_factory'
require 'awrence'
require 'plissken'

module Dandy
  class Request
    include Hypo::Scope

    def initialize(route_matcher, container, chain_factory, view_factory)
      @container = container
      @route_matcher = route_matcher
      @chain_factory = chain_factory
      @view_factory = view_factory
    end

    def handle(rack_env)
      create_scope

      path = rack_env['PATH_INFO']
      request_method = rack_env['REQUEST_METHOD']
      match = @route_matcher.match(path, request_method)

      headers = Hash[
        *rack_env.select {|k, v| k.start_with? 'HTTP_'}
           .collect {|k, v| [k.sub(/^HTTP_/, ''), v]}
           .collect {|k, v| [k.split('_').collect(&:capitalize).join('-'), v]}
           .flatten
      ]
      register_params(headers, :dandy_headers)

      if match.nil?
        result = [404, {'Content-Type' => headers['Accept']}, []]
      else
        query = Rack::Utils.parse_nested_query(rack_env['QUERY_STRING']).to_snake_keys.symbolize_keys
        register_params(query, :dandy_query)

        data = rack_env['rack.parser.result'] ? rack_env['rack.parser.result'].to_snake_keys.deep_symbolize_keys! : nil
        register_params(data, :dandy_data)

        chain = @chain_factory.create(match)
        chain_result = chain.execute

        if match.route.view
          body = @view_factory.create(match.route.view, headers['Accept'], {keys_format: headers['Keys-Format'] || 'snake'})
        else
          if chain_result.is_a?(String)
            body = chain_result
          else # generate JSON when nothing other is requested
            if headers['Keys-Format'] == 'camel' && chain_result
              chain_result = chain_result.to_camelback_keys
            end

            body = JSON.generate(chain_result)
          end
        end

        status = @container.resolve(:dandy_status)
        result = [status, {'Content-Type' => headers['Accept']}, [body]]
      end

      release

      result
    end

    private

    def create_scope
      @container
        .register_instance(self, :dandy_request)
        .using_lifetime(:scope)
        .bound_to(self)
    end

    def register_params(params, name)
      unless params.nil?
        @container.register_instance(params, name)
          .using_lifetime(:scope)
          .bound_to(:dandy_request)
      end
    end
  end
end