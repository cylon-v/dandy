require 'spec_helper'
require 'dandy/chain'
require 'rack'

RSpec.describe Dandy::Request do
  describe 'handle' do
    before :each do
      @rack_env = {
        'PATH_INFO' => '/user/1/update',
        'REQUEST_METHOD' => 'PATCH',
        'HTTP_ACCEPT' => 'application/json',
        'HTTP_CACHE_CONTROL' => 'no-cache'
      }

      @scope_lifetime = double(:scope_lifetime)
      allow(@scope_lifetime).to receive(:purge)

      @container = double(:container, lifetimes: {scope: @scope_lifetime})

      @route_matcher = double(:route_matcher)
      @chain_factory = double(:chain_factory)
      @view_factory = double(:view_factory)

      @request_component = double(:request_component)
      allow(@request_component).to receive(:using_lifetime).and_return(@request_component)
      allow(@request_component).to receive(:bound_to).and_return(@request_component)

      @request = Dandy::Request.new(@route_matcher, @container, @chain_factory, @view_factory)

      allow(Rack::Multipart).to receive(:parse_multipart).and_return(nil)

      allow(@container).to receive(:register_instance)
                             .with([], :dandy_files)
                             .and_return(@request_component)

      allow(@container).to receive(:register_instance)
                             .with({'Accept' => 'application/json', 'Cache-Control' => 'no-cache'}, :dandy_headers)
                             .and_return(@request_component)

      allow(@container).to receive(:register_instance).with(@request, :dandy_request)
                             .and_return(@request_component)
    end

    context 'when route not matched' do
      before :each do
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
        @view_name = 'some_view'
        @status = 200

        @chain = double(:chain)
        allow(@chain).to receive(:execute)
        allow(@chain_factory).to receive(:create).and_return(@chain)

        allow(@container).to receive(:resolve).with(:dandy_status).and_return(@status)

        @result_component = double(:result_component)
        allow(@result_component).to receive(:using_lifetime).with(:scope).and_return(@result_component)
        allow(@result_component).to receive(:bound_to).with(:dandy_request)

        form_data = {
          field1: "one",
          field2: {
            nestedField: 1
          }
        }

        @rack_env = {
          'PATH_INFO' => '/user/1/update',
          'REQUEST_METHOD' => 'PATCH',
          'QUERY_STRING' => 'x=1&y=two',
          'HTTP_ACCEPT' => 'application/json',
          'HTTP_CACHE_CONTROL' => 'no-cache',
          'rack.parser.result' => form_data
        }
      end

      context 'when view is defined' do
        before :each do
          route = double(:route, {view: @view_name})
          match = double(:match, {route: route})
          allow(@route_matcher).to receive(:match).and_return(match)

          @body = 'some response body'
          allow(@view_factory).to receive(:create).with(@view_name, 'application/json', {keys_format: 'snake'}).and_return(@body)
        end

        context 'when client wants to receive keys in camel format' do
          before :each do
            @rack_env_camel = {
              'PATH_INFO' => '/user/1/update',
              'REQUEST_METHOD' => 'PATCH',
              'HTTP_ACCEPT' => 'application/json',
              'HTTP_KEYS_FORMAT' => 'camel'
            }

            allow(@container).to receive(:register_instance)
                                   .with({'Accept' => 'application/json', 'Cache-Control' => 'no-cache'}, :dandy_headers)
                                   .and_return(@result_component)

            allow(@container).to receive(:register_instance)
                                   .with({}, :dandy_query)
                                   .and_return(@result_component)

            allow(@container).to receive(:register_instance)
                                   .with({}, :dandy_data)
                                   .and_return(@result_component)
          end

          it 'creates view with such option' do
            expect(@container).to receive(:register_instance)
                                    .with({'Accept' => 'application/json', 'Keys-Format' => 'camel'}, :dandy_headers)
                                    .and_return(@result_component)

            expect(@view_factory).to receive(:create).with(@view_name, 'application/json', {keys_format: 'camel'}).and_return(@body)
            @request.handle(@rack_env_camel)
          end
        end


        it 'correctly parses and registers query params and form data and files' do
          expect(@container).to receive(:register_instance)
                                  .with({'Accept' => 'application/json', 'Cache-Control' => 'no-cache'}, :dandy_headers)
                                  .and_return(@result_component)

          expect(@container).to receive(:register_instance)
                                  .with({x: '1', y: 'two'}, :dandy_query)
                                  .and_return(@result_component)

          expect(@container).to receive(:register_instance)
                                  .with({field1: 'one', field2: {nested_field: 1}}, :dandy_data)
                                  .and_return(@result_component)

          expect(@container).to receive(:register_instance)
                                  .with([], :dandy_files)
                                  .and_return(@result_component)

          @request.handle(@rack_env)
        end

        it 'creates and executes the chain' do
          allow(@container).to receive(:register_instance)
                                 .with({'Accept' => 'application/json', 'Cache-Control' => 'no-cache'}, :dandy_headers)
                                 .and_return(@result_component)

          allow(@container).to receive(:register_instance)
                                 .with({x: '1', y: 'two'}, :dandy_query)
                                 .and_return(@result_component)

          allow(@container).to receive(:register_instance)
                                 .with({field1: 'one', field2: {nested_field: 1}}, :dandy_data)
                                 .and_return(@result_component)

          expect(@chain_factory).to receive(:create)
          expect(@chain).to receive(:execute)

          @request.handle(@rack_env)
        end

        it 'returns correct result' do
          allow(@container).to receive(:register_instance)
                                 .with({'Accept' => 'application/json', 'Cache-Control' => 'no-cache'}, :dandy_headers)
                                 .and_return(@result_component)


          allow(@container).to receive(:register_instance)
                                 .with({x: '1', y: 'two'}, :dandy_query)
                                 .and_return(@result_component)

          allow(@container).to receive(:register_instance)
                                 .with({field1: 'one', field2: {nested_field: 1}}, :dandy_data)
                                 .and_return(@result_component)

          expect(@chain_factory).to receive(:create)
          expect(@chain).to receive(:execute)

          result = @request.handle(@rack_env)
          expect(result[0]).to eql(@status)
          expect(result[1]).to eql({'Content-Type' => 'application/json'})
          expect(result[2]).to eql([@body])
        end
      end

      context 'when view is not defined' do
        before :each do
          route = double(:route, {view: nil})
          match = double(:match, {route: route})
          allow(@route_matcher).to receive(:match).and_return(match)

          allow(@container).to receive(:register_instance)
                                 .with({'Accept' => 'application/json', 'Cache-Control' => 'no-cache'}, :dandy_headers)
                                 .and_return(@result_component)


          allow(@view_factory).to receive(:create).with(@view_name, 'application/json').and_return(nil)
          allow(@container).to receive(:register_instance)
                                 .with({x: '1', y: 'two'}, :dandy_query)
                                 .and_return(@result_component)

          allow(@container).to receive(:register_instance)
                                 .with({field1: 'one', field2: {nested_field: 1}}, :dandy_data)
                                 .and_return(@result_component)

          allow(@chain_factory).to receive(:create).and_return(@chain)
        end

        context 'when result is a String' do
          it 'returns it as is' do
            allow(@chain).to receive(:execute).and_return('some-string-result')

            result = @request.handle(@rack_env)
            expect(result[2]).to eql(['some-string-result'])
          end
        end

        context 'when result is an Object (i.e. Hash)' do
          before :each do
            allow(@chain).to receive(:execute).and_return({some_result: 'value'})
          end

          it 'returns JSON' do
            result = @request.handle(@rack_env)
            expect(result[2]).to eql(['{"some_result":"value"}'])
          end

          context 'when client wants to receive keys in camel format' do
            before :each do
              @rack_env_camel = {
                'PATH_INFO' => '/user/1/update',
                'REQUEST_METHOD' => 'PATCH',
                'HTTP_ACCEPT' => 'application/json',
                'HTTP_KEYS_FORMAT' => 'camel'
              }

              allow(@container).to receive(:register_instance)
                                     .with({}, :dandy_query)
                                     .and_return(@result_component)

              allow(@container).to receive(:register_instance)
                                     .with({}, :dandy_data)
                                     .and_return(@result_component)

              allow(@container).to receive(:register_instance)
                                     .with({'Accept' => 'application/json', 'Keys-Format' => 'camel'}, :dandy_headers)
                                     .and_return(@result_component)
            end

            it 'returns camelized JSON' do
              result = @request.handle(@rack_env_camel)
              expect(result[2]).to eql(['{"someResult":"value"}'])
            end
          end
        end
      end
    end
  end
end
