require 'silicon/chain_factory'
require 'silicon/view_factory'

module Silicon
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
        register_params(query, :silicon_query)

        data = rack_env['rack.parser.result']
        register_params(data, :silicon_data)

        chain = @chain_factory.create(match)
        chain.execute

        body = ''
        if match.route.view
          body = @view_factory.create(match.route.view, content_type)
        end

        status = @container.resolve(:silicon_status)
        result = [status, { 'Content-Type' => content_type }, [body]]
      end

      release

      result
    end

    private
    def create_scope
      @container
        .register_instance(self, :silicon_request)
        .using_lifetime(:scope)
        .bound_to(self)
    end

    def register_params(params, name)
      unless params.nil?
        @container.register_instance(params, name)
          .using_lifetime(:scope)
          .bound_to(:silicon_request)
      end
    end
  end
end