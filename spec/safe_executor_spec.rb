require 'spec_helper'
require 'dandy/safe_executor'
require 'dandy/chain'

RSpec.describe Dandy::SafeExecutor do
  describe 'execute' do
    before :each do
      @component = double(:component)
      allow(@component).to receive(:using_lifetime).and_return(@component)
      allow(@component).to receive(:bound_to)

      @container = double(:container)
      allow(@container).to receive(:register_instance).and_return(@component)

      dandy_config = double(:dandy_config)

      @view_factory = double(@view_factory)

      @chain = double(:chain)
      allow(Dandy::Chain).to receive(:new).and_return(@chain)

      @route = double(:route)
      allow(@route).to receive(:commands)
      allow(@route).to receive(:last_command)

      @headers = double(:headers)
      allow(@headers).to receive(:[]).with('Accept').and_return('application/json')
      allow(@headers).to receive(:[]).with('Keys-Format').and_return('camel')

      @safe_executor = Dandy::SafeExecutor.new(@container, dandy_config, @view_factory)
    end

    context 'when an exception is thrown' do
      before :each do
        @error = StandardError.new
        allow(@chain).to receive(:run_commands).and_raise(@error)

        @catch_command = double(:catch_command, name: 'catch')

        @catch_action = double(:catch_action)
        allow(@catch_action).to receive(:call).and_return(some_message: 'some-error')

        allow(@route).to receive(:view).and_return(nil)
        allow(@route).to receive(:catch).and_return(@catch_command)

        allow(@container).to receive(:resolve).with(:catch).and_return(@catch_action)
      end

      it 'registers dandy error' do
        expect(@container).to receive(:register_instance).with(@error, :dandy_error)
        expect(@component).to receive(:bound_to).with(:dandy_request)

        @safe_executor.execute(@route, @headers)
      end

      it 'returns output of catch action' do
        result = @safe_executor.execute(@route, @headers)
        expect(result).to eql('{"someMessage":"some-error"}')
      end
    end

    context 'without no exception' do
      context 'when view is specified for the route' do
        before :each do
          @view = double(:view)
          allow(@route).to receive(:view).and_return(@view)

          allow(@chain).to receive(:run_commands)

          @view_body = {name: 'Name', last_name: 'Last Name'}

          allow(@view_factory).to receive(:create).with(@view, 'application/json', keys_format: 'camel')
            .and_return(@view_body)
        end

        it 'returns a view body created by view_factory' do
          result = @safe_executor.execute(@route, @headers)
          expect(result).to eql('{"name":"Name","lastName":"Last Name"}')
        end
      end

      context 'when view is not specified for the route' do
        before :each do
          allow(@route).to receive(:view).and_return(nil)
        end

        context 'and result is a string' do
          before :each do
            allow(@chain).to receive(:run_commands).and_return('some-string')
          end

          it 'returns the string as is' do
            result = @safe_executor.execute(@route, @headers)
            expect(result).to eql('some-string')
          end
        end

        context 'and result is not a string' do
          before :each do
            allow(@chain).to receive(:run_commands).and_return(some_data: 'some result')
          end

          context 'and requested format is "camel"' do
            before :each do
              allow(@headers).to receive(:[]).with('Keys-Format').and_return('camel')
            end

            it 'returns camel-formatted json' do
              result = @safe_executor.execute(@route, @headers)
              expect(result).to eql('{"someData":"some result"}')
            end
          end

          context 'and requested format is "snake"' do
            before :each do
              allow(@headers).to receive(:[]).with('Keys-Format').and_return('snake')
            end

            it 'returns snake-formatted json (ruby-style)' do
              result = @safe_executor.execute(@route, @headers)
              expect(result).to eql('{"some_data":"some result"}')
            end
          end
        end
      end
    end
  end
end
