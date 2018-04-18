require 'dandy/chain_factory'
require 'dandy/view_factory'

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
      content_type = rack_env['CONTENT_TYPE'] || 'application/json'

      if match.nil?
        result = [404, { 'Content-Type' => content_type }, []]
      else
        query = Rack::Utils.parse_nested_query(rack_env['QUERY_STRING']).symbolize_keys
        register_params(query, :dandy_query)

        data = rack_env['rack.parser.result']
        register_params(data, :dandy_data)

        chain = @chain_factory.create(match)
        result = chain.execute

        body = match.route.view ? @view_factory.create(match.route.view, content_type) : result

        status = @container.resolve(:dandy_status)
        result = [status, { 'Content-Type' => content_type }, [body]]
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