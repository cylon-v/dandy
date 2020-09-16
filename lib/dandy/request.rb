require 'json'
require 'awrence'
require 'plissken'
require 'rack/multipart'
require 'dandy/extensions/hash'
require 'dandy/view_factory'
require 'dandy/chain'

module Dandy
  class Request
    include Hypo::Scope

    def initialize(route_matcher, container, route_executor)
      @container = container
      @route_matcher = route_matcher
      @route_executor = route_executor
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

      register_context(headers, :dandy_headers)

      if match.nil?
        result = [404, {'Content-Type' => headers['Accept']}, []]
        release
      else
        status = match.route.http_status || default_http_status(match.route.http_verb)
        register_params(match.params)
        register_status(status)

        query = Rack::Utils.parse_nested_query(rack_env['QUERY_STRING']).to_snake_keys.symbolize_keys
        register_context(query, :dandy_query)

        data = rack_env['rack.parser.result'] ? rack_env['rack.parser.result'].to_snake_keys.deep_symbolize_keys! : {}
        register_context(data, :dandy_data)

        multipart = Rack::Multipart.parse_multipart(rack_env) || {}
        register_context(multipart.values, :dandy_files)

        begin
          body = @route_executor.execute(match.route, headers)
          release
        rescue Exception => error
          body = @route_executor.handle_error(match.route, headers, error)
        end

        status = @container.resolve(:dandy_status)
        result = [status, {'Content-Type' => 'application/json'}, [body]]
      end


      result
    end

    private

    def create_scope
      @container
        .register_instance(self, :dandy_request)
        .using_lifetime(:scope)
        .bound_to(self)
    end

    def register_context(params, name)
      unless params.nil?
        @container.register_instance(params, name)
          .using_lifetime(:scope)
          .bound_to(:dandy_request)
      end
    end

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