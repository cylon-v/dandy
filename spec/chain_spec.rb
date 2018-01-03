require 'spec_helper'
require 'silicon/chain'

RSpec.describe Silicon::Chain do
  describe 'execute' do
    before :each do
      @silicon_config = {
        action: {
          async_timeout: 5
        }
      }
      @container = double(:container)

      @command1 = double(:command1)
      allow(@command1).to receive(:name).and_return('command1')
      allow(@command1).to receive(:call).and_return('command1 result')
      allow(@container).to receive(:resolve).with(:command1).and_return(@command1)

      @command2 = double(:command2)
      allow(@command2).to receive(:name).and_return('command2')
      allow(@command2).to receive(:call).and_return('command2 result')
      allow(@container).to receive(:resolve).with(:command2).and_return(@command2)

      @command3 = double(:command3)
      allow(@command3).to receive(:name).and_return('command3')
      allow(@command3).to receive(:call).and_return('command3 result')
      allow(@container).to receive(:resolve).with(:command3).and_return(@command3)

      @catch_command = double(:catch_command)
      allow(@catch_command).to receive(:name).and_return('handle_errors')
      allow(@catch_command).to receive(:call)
      allow(@container).to receive(:resolve).with(:handle_errors).and_return(@catch_command)


      allow(@container).to receive(:resolve).with('catch').and_return(@catch_command)
      @commands = [@command1, @command2, @command3]

      component1 = double(:component1)
      allow(component1).to receive_message_chain('using_lifetime.bound_to')
      allow(@container).to receive(:register_instance).with('command1 result', :command1_result)
                             .and_return(component1)

      component2 = double(:component2)
      allow(component2).to receive_message_chain('using_lifetime.bound_to')
      allow(@container).to receive(:register_instance).with('command2 result', :command2_result)
                             .and_return(component2)

      component3 = double(:component3)
      allow(component3).to receive_message_chain('using_lifetime.bound_to')
      allow(@container).to receive(:register_instance).with('command3 result', :command3_result)
                             .and_return(component3)

      @chain = Silicon::Chain.new(@container, @silicon_config, @commands, @catch_command)
    end

    context '-> command1 -> command2 -> command3 :catch' do
      before :each do
        allow(@command1).to receive(:sequential?).and_return(true)
        allow(@command2).to receive(:sequential?).and_return(true)
        allow(@command3).to receive(:sequential?).and_return(true)
      end

      it 'all sequential commands should be executed in correct order' do
        expect(@command1).to receive(:call).ordered
        expect(@command2).to receive(:call).ordered
        expect(@command3).to receive(:call).ordered

        @chain.execute
      end

      context 'when command1 raises exception' do
        before :each do
          @error = StandardError.new
          allow(@command1).to receive(:call).and_raise(@error)

          error_command = double(:error_command)
          allow(error_command).to receive_message_chain('using_lifetime.bound_to')
          allow(@container).to receive(:register_instance).with(@error, :silicon_error)
                                 .and_return(error_command)
        end

        it 'catch action should be called' do
          expect(@catch_command).to receive(:call)
          @chain.execute
        end

        it 'further commands should not be executed' do
          expect(@command2).not_to receive(:call)
          expect(@command3).not_to receive(:call)
          @chain.execute
        end

        it 'silicon_error should be registered in container' do
          expect(@container).to receive(:register_instance).with(@error, :silicon_error)
          @chain.execute
        end
      end
    end

    context '=> command1 => command2 -> command3 :catch' do
      before :each do
        @order = []
        allow(@command1).to receive(:parallel?).and_return(true)
        allow(@command1).to receive(:sequential?).and_return(false)
        allow(@command1).to receive(:call) do
          sleep(0.2)
          @order << 1
          'command1 result'
        end

        allow(@command2).to receive(:parallel?).and_return(true)
        allow(@command2).to receive(:sequential?).and_return(false)
        allow(@command2).to receive(:call) do
          sleep(0.1)
          @order << 2
          'command2 result'
        end

        allow(@command3).to receive(:sequential?).and_return(true)
        allow(@command3).to receive(:call) do
          @order << 3
          'command3 result'
        end
      end

      it 'commands should be executed in correct order (parallel commands should be completed before the next sequential)' do
        @chain.execute
        expect(@order).to eql([2, 1, 3])
      end

      context 'when first raises exception' do
        before :each do
          @error = StandardError.new
          allow(@command1).to receive(:call) do
            sleep(0.2)
            raise @error
          end

          error_command = double(:error_command)
          allow(error_command).to receive_message_chain('using_lifetime.bound_to')
          allow(@container).to receive(:register_instance).with(@error, :silicon_error)
                                 .and_return(error_command)
        end

        it 'catch action should be called' do
          expect(@catch_command).to receive(:call)
          @chain.execute
        end

        it 'further sequential commands should not be executed' do
          expect(@command3).not_to receive(:call)
          @chain.execute
        end

        it 'silicon_error should be registered in container' do
          expect(@container).to receive(:register_instance).with(@error, :silicon_error)
          @chain.execute
        end
      end
    end

    context '=> command1 => command2 => command3 :catch' do
      before :each do
        allow(@command1).to receive(:parallel?).and_return(true)
        allow(@command1).to receive(:sequential?).and_return(false)

        allow(@command2).to receive(:parallel?).and_return(true)
        allow(@command2).to receive(:sequential?).and_return(false)

        allow(@command3).to receive(:parallel?).and_return(true)
        allow(@command3).to receive(:sequential?).and_return(false)
      end

      it 'all parallel commands should be completed on chain completed' do
        expect(@command1).to receive(:call)
        expect(@command2).to receive(:call)
        expect(@command3).to receive(:call)

        @chain.execute
      end
    end

    context '*> command1 *> command2 -> command3 :catch' do
      before :each do
        @order = []
        allow(@command1).to receive(:parallel?).and_return(false)
        allow(@command1).to receive(:sequential?).and_return(false)
        allow(@command1).to receive(:call) do
          sleep(0.1)
          @order << 1
          'command1 result'
        end

        allow(@command2).to receive(:parallel?).and_return(false)
        allow(@command2).to receive(:sequential?).and_return(false)
        allow(@command2).to receive(:call) do
          sleep(0.1)
          @order << 2
          'command2 result'
        end

        allow(@command3).to receive(:sequential?).and_return(true)
        allow(@command3).to receive(:call) do
          @order << 3
          'command3 result'
        end
      end

      it 'async commands may not be completed before the next sequential' do
        @chain.execute
        expect(@order).to eql([3])
        sleep(0.2) # wait until rspec doubles released
      end
    end

    context '*> command1 *> command2 *> command3 :catch' do
      before :each do
        @order = []
        allow(@command1).to receive(:parallel?).and_return(false)
        allow(@command1).to receive(:sequential?).and_return(false)
        allow(@command1).to receive(:call) do
          sleep(0.1)
          @order << 1
          'command1 result'
        end

        allow(@command2).to receive(:parallel?).and_return(false)
        allow(@command2).to receive(:sequential?).and_return(false)
        allow(@command2).to receive(:call) do
          sleep(0.1)
          @order << 2
          'command2 result'
        end

        allow(@command3).to receive(:parallel?).and_return(false)
        allow(@command3).to receive(:sequential?).and_return(false)
        allow(@command3).to receive(:call) do
          sleep(0.1)
          @order << 3
          'command3 result'
        end
      end

      it 'async commands may not be completed on chain completed' do
        @chain.execute
        expect(@order).to eql([])
        sleep(0.2) # wait until rspec doubles released
      end
    end

    context 'when catch command is not defined' do
      before :each do
        @chain = Silicon::Chain.new(@container, @silicon_config, @commands)
      end

      context 'and a chain command raises an error' do
        before :each do
          @error = StandardError.new
          allow(@command1).to receive(:sequential?).and_return(true)
          allow(@command2).to receive(:sequential?).and_return(true)
          allow(@command3).to receive(:sequential?).and_return(true)

          allow(@command1).to receive(:call).and_raise(@error)
        end

        it 'throws the error up' do
          expect {@chain.execute}.to raise_error(@error)
        end
      end
    end
  end
end
