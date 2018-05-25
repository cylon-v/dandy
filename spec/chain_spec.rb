require 'spec_helper'
require 'dandy/chain'

RSpec.describe Dandy::Chain do
  describe 'run_commands' do
    before :each do
      @dandy_config = {
        action: {
          async_timeout: 5
        }
      }
      @container = double(:container)

      @command1 = double(:command1)
      allow(@command1).to receive(:name).and_return('command1')
      allow(@command1).to receive(:result_name).and_return('command1_result')
      allow(@command1).to receive(:call).and_return('command1 result')
      allow(@command1).to receive(:entity?).and_return(false)
      allow(@container).to receive(:resolve).with(:command1).and_return(@command1)

      @command2 = double(:command2)
      allow(@command2).to receive(:name).and_return('command2')
      allow(@command2).to receive(:result_name).and_return('command2_result')
      allow(@command2).to receive(:call).and_return('command2 result')
      allow(@command2).to receive(:entity?).and_return(false)
      allow(@container).to receive(:resolve).with(:command2).and_return(@command2)

      @command3 = double(:command3)
      allow(@command3).to receive(:name).and_return('command3')
      allow(@command3).to receive(:result_name).and_return('command3_result')
      allow(@command3).to receive(:call).and_return('command3 result')
      allow(@command3).to receive(:entity?).and_return(false)
      allow(@container).to receive(:resolve).with(:command3).and_return(@command3)

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

      @headers = {
        'Accept': 'application/json',
        'Keys-Format': 'camel'
      }

      @chain = Dandy::Chain.new(@container, @dandy_config)
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

        @chain.run_commands(@commands, @command3)
      end

      it 'returns last command result' do
        result1 = 'command1 result'
        result2 = 'command2 result'
        result3 = 'command3 result'

        allow(@command1).to receive(:call).and_return(result1)
        allow(@command2).to receive(:call).and_return(result2)
        allow(@command3).to receive(:call).and_return(result3)

        expect(@chain.run_commands(@commands, @command3)).to eql(result3)
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
        @chain.run_commands(@commands, @command3)
        expect(@order).to eql([2, 1, 3])
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

        @chain.run_commands(@commands, @command3)
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
        @chain.run_commands(@commands, @command3)
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
        @chain.run_commands(@commands, @command3)
        expect(@order).to eql([])
        sleep(0.2) # wait until rspec doubles released
      end
    end

    context '(with :after section) -> command1 -> command2 -> :after :catch' do
      before :each do
        @after_command = double(:after_command)
        allow(@after_command).to receive(:name).and_return('after')
        allow(@after_command).to receive(:result_name).and_return('after_result')
        allow(@after_command).to receive(:call).and_return('after result')
        allow(@container).to receive(:resolve).with(:after_command).and_return(@after_command)

        allow(@command1).to receive(:sequential?).and_return(true)
        allow(@command2).to receive(:sequential?).and_return(true)
        allow(@command3).to receive(:sequential?).and_return(true)
      end

      it 'result from last command from main chain should be returned (ignore :after)' do
        expect(@chain.run_commands(@commands, @command3)).to eql('command3 result')
      end
    end

    context 'when command2 is an entity with method like "user.like"' do
      before :each do
        @entity = double(:entity)
        @entity_class = double(:entity_class)
        @parameter = double(:parameter)
        @parameters = [[:req, :comment]]
        @instance_method = double(:instance_method)
        @method_result = double(:method_result)

        allow(@command2).to receive(:sequential?).and_return(true)
        allow(@entity_class).to receive(:instance_method).and_return(@instance_method)
        allow(@entity).to receive(:class).and_return(@entity_class)
        allow(@instance_method).to receive(:parameters).and_return(@parameters)
        allow(@command2).to receive(:entity?).and_return(true)
        allow(@command2).to receive(:entity_name).and_return('user')
        allow(@command2).to receive(:entity_method).and_return('like')

        @chain = Dandy::Chain.new(@container, @dandy_config)
      end

      it 'calls entity method' do
        expect(@container).to receive(:resolve).with(:user).and_return(@entity)
        expect(@container).to receive(:resolve).with(:comment).and_return(@parameter)
        expect(@entity).to receive(:like).with(@parameter).and_return(@method_result)

        result_component = double(:result_component)
        allow(result_component).to receive_message_chain('using_lifetime.bound_to')
        expect(@container).to receive(:register_instance).with(@method_result, :command2_result)
                               .and_return(result_component)


        @chain.run_commands([@command2], @command2)
      end
    end
  end
end
