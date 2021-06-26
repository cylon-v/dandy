require 'spec_helper'
require 'dandy/chain'
require 'rack'

RSpec.describe Dandy::Request do
  describe 'handle' do
    let(:scope_lifetime) { double(:scope_lifetime) }
    let(:container) { double(:container, lifetimes: {scope: scope_lifetime}) }
    let(:route_matcher) { double(:route_matcher) }
    let(:route_executor) { double(:route_executor) }
    let(:request_component) { double(:request_component) }
    let(:result_component) { double(:result_component) }

    let :expected_headers do
      {
        'Accept' => 'application/json',
        'Cache-Control' => 'no-cache'
      }
    end

    let :request do
      Dandy::Request.new(route_matcher, container, route_executor)
    end

    let :rack_env do
      {
        'PATH_INFO' => '/user/1/update',
        'REQUEST_METHOD' => 'PATCH',
        'HTTP_ACCEPT' => 'application/json',
        'HTTP_CACHE_CONTROL' => 'no-cache'
      }
    end

    before :each do
      allow(scope_lifetime).to receive(:purge)

      allow(request_component).to receive(:using_lifetime).and_return(request_component)
      allow(request_component).to receive(:bound_to).and_return(request_component)

      allow(result_component).to receive(:using_lifetime).and_return(result_component)
      allow(result_component).to receive(:bound_to)

      allow(Rack::Multipart).to receive(:parse_multipart).and_return(nil)

      allow(container).to receive(:register_instance)
                             .with([], :dandy_files)
                             .and_return(request_component)

      allow(container).to receive(:register_instance)
                             .with({'Accept' => 'application/json', 'Cache-Control' => 'no-cache'}, :dandy_headers)
                             .and_return(request_component)

      allow(container).to receive(:register_instance).with(request, :dandy_request)
                             .and_return(request_component)
    end

    context 'when route not matched' do
      before :each do
        allow(route_matcher).to receive(:match).and_return(nil)
      end

      it 'registers HTTP headers' do
        expect(container).to receive(:register_instance)
                                .with(expected_headers, :dandy_headers).and_return(result_component)
        request.handle(rack_env)
      end

      it 'returns 404' do
        result = request.handle(rack_env)
        expect(result[0]).to eql(404)
      end

      it 'releases the scope' do
        expect(scope_lifetime).to receive(:purge)
        request.handle(rack_env)
      end
    end

    context 'when route matched' do
      let(:status) { 423 }
      let(:route) { double(:route) }
      let(:match) { double(:match) }

      let :params do
        {id: 1}
      end

      let :form_data do
        {
          field1: "one",
          field2: {
            nestedField: 1
          }
        }
      end

      let :rack_env do
        {
          'PATH_INFO' => '/user/1/update',
          'REQUEST_METHOD' => 'PATCH',
          'QUERY_STRING' => 'x=1&y=two',
          'HTTP_ACCEPT' => 'application/json',
          'HTTP_CACHE_CONTROL' => 'no-cache',
          'rack.parser.result' => form_data
        }
      end

      before :each do
        allow(route).to receive(:http_status).and_return(status)

        allow(match).to receive(:route).and_return(route)
        allow(match).to receive(:params).and_return(params)
        allow(route_matcher).to receive(:match).and_return(match)

        allow(route_executor).to receive(:execute)
        allow(container).to receive(:register_instance).and_return(result_component)

        allow(container).to receive(:resolve).with(:dandy_status).and_return(status)
      end

      it 'registers HTTP headers' do
        expect(container).to receive(:register_instance)
                                .with(expected_headers, :dandy_headers).and_return(result_component)
        request.handle(rack_env)
      end

      context 'when HTTP status is not specified in the route' do
        before :each do
          allow(route).to receive(:http_status).and_return(nil)
          allow(route).to receive(:http_verb).and_return('GET')
        end

        it 'registers default HTTP status for the verb' do
          expect(container).to receive(:register_instance)
                                  .with(200, :dandy_status).and_return(result_component)
          request.handle(rack_env)
        end
      end

      context 'when HTTP status is specified in the route' do
        before :each do
          allow(route).to receive(:http_status).and_return(status)
        end

        it 'registers the status' do
          expect(container).to receive(:register_instance)
                                  .with(status, :dandy_status).and_return(result_component)
          request.handle(rack_env)
        end
      end


      it 'registers HTTP parameters' do
        expect(container).to receive(:register_instance)
                                .with(params[:id], :id).and_return(result_component)
        request.handle(rack_env)
      end

      it 'registers HTTP query parameters' do
        query_params = {x: 1, y: 'two'}
        allow(Rack::Utils).to receive(:parse_nested_query).and_return(query_params)

        expect(container).to receive(:register_instance)
                                .with(query_params, :dandy_query).and_return(result_component)
        request.handle(rack_env)
      end

      it 'registers HTTP form data' do
        expected_data = {
          field1: "one",
          field2: {
            nested_field: 1
          }
        }

        expect(container).to receive(:register_instance)
                                .with(expected_data, :dandy_data).and_return(result_component)

        request.handle(rack_env)
      end

      it 'registers uploaded files' do
        file1 = {name: 'file1'}
        file2 = {name: 'file2'}

        files = {file1: file1, file2: file2}
        allow(Rack::Multipart).to receive(:parse_multipart).and_return(files)

        expect(container).to receive(:register_instance)
                                .with([file1, file2], :dandy_files).and_return(result_component)
        request.handle(rack_env)
      end

      it 'pass the flow to safe_executor' do
        expect(route_executor).to receive(:execute).with(route, expected_headers)
        request.handle(rack_env)
      end

      it 'returns correct response' do
        body = {data: 'some data'}
        allow(route_executor).to receive(:execute).and_return(body)
        expect(request.handle(rack_env)).to eql([status, {'Content-Type' => 'application/json'}, [body]])
      end

      context 'when error raised on the scope releasing' do
        let(:error) {StandardError.new('Error')}

        before :each do
          allow(request).to receive(:release).and_raise error
        end

        it 'pass error handling to safe_executor' do
          expect(route_executor).to receive(:handle_error).with(route, expected_headers, error)
          request.handle(rack_env)
        end
      end
    end
  end
end
