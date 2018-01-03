require 'spec_helper'
require 'silicon/chain'
require 'rack'

RSpec.describe Silicon::Request do
  describe 'handle' do
    before :each do
      @scope_lifetime = double(:scope_lifetime)
      allow(@scope_lifetime).to receive(:purge)

      @container = double(:container, lifetimes: {scope: @scope_lifetime})

      @route_matcher = double(:route_matcher)
      @chain_factory = double(:chain_factory)
      @view_factory = double(:view_factory)

      @request_component = double(:request_component)
      allow(@request_component).to receive(:using_lifetime).and_return(@request_component)
      allow(@request_component).to receive(:bound_to).and_return(@request_component)

      @request = Silicon::Request.new(@route_matcher, @container, @chain_factory, @view_factory)
      allow(@container).to receive(:register_instance).with(@request, :silicon_request)
                             .and_return(@request_component)
    end

    context 'when route not matched' do
      before :each do
        @rack_env = {
          'PATH_INFO' => '/user/1/update',
          'REQUEST_METHOD' => 'PATCH'
        }
        allow(@route_matcher).to receive(:match).and_return(nil)
      end

      it 'returns 404' do
        result = @request.handle(@rack_env)
        expect(result[0]).to eql(404)
      end

      it 'releases' do
        expect(@scope_lifetime).to receive(:purge)
        @request.handle(@rack_env)
      end
    end

    context 'when route matched' do
      before :each do
        view_name = 'some_view'
        @status = 200

        route = double(:route, {view: view_name})
        match = double(:match, {route: route})
        allow(@route_matcher).to receive(:match).and_return(match)

        @chain = double(:chain)
        allow(@chain).to receive(:execute)
        allow(@chain_factory).to receive(:create).and_return(@chain)

        @body = 'some response body'
        allow(@view_factory).to receive(:create).with(view_name, 'application/json').and_return(@body)

        allow(@container).to receive(:resolve).with(:silicon_status).and_return(@status)

        @result_component = double(:result_component)
        allow(@result_component).to receive(:using_lifetime).with(:scope).and_return(@result_component)
        allow(@result_component).to receive(:bound_to).with(:silicon_request)

        form_data = {
          field1: "one",
          field2: {
            nested_field: 1
          }
        }

        @rack_env = {
          'PATH_INFO' => '/user/1/update',
          'REQUEST_METHOD' => 'PATCH',
          'QUERY_STRING' => 'x=1&y=two',
          'rack.parser.result' => form_data
        }
      end

      it 'correctly parses and registers query params and form data' do
        expect(@container).to receive(:register_instance)
                                .with({x: '1', y: 'two'}, :silicon_query)
                                .and_return(@result_component)

        expect(@container).to receive(:register_instance)
                                .with({field1: 'one', field2: {nested_field: 1}}, :silicon_data)
                                .and_return(@result_component)

        @request.handle(@rack_env)
      end

      it 'creates and executes the chain' do
        allow(@container).to receive(:register_instance)
                                .with({x: '1', y: 'two'}, :silicon_query)
                                .and_return(@result_component)

        allow(@container).to receive(:register_instance)
                                .with({field1: 'one', field2: {nested_field: 1}}, :silicon_data)
                                .and_return(@result_component)

        expect(@chain_factory).to receive(:create)
        expect(@chain).to receive(:execute)

        @request.handle(@rack_env)
      end

      it 'returns correct result' do
        allow(@container).to receive(:register_instance)
                               .with({x: '1', y: 'two'}, :silicon_query)
                               .and_return(@result_component)

        allow(@container).to receive(:register_instance)
                               .with({field1: 'one', field2: {nested_field: 1}}, :silicon_data)
                               .and_return(@result_component)

        expect(@chain_factory).to receive(:create)
        expect(@chain).to receive(:execute)

        result = @request.handle(@rack_env)
        expect(result[0]).to eql(@status)
        expect(result[1]).to eql({ 'Content-Type' => 'application/json'})
        expect(result[2]).to eql([@body])
      end
    end
  end
end
