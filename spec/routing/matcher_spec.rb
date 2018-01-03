require 'spec_helper'
require 'silicon/routing/matcher'

RSpec.describe Silicon::Routing::Matcher do
  describe 'match' do
    context 'when there is no matching route' do
      before :all do
        routes = [
          Silicon::Routing::Route.new(http_verb: 'GET', path: '/not-found')
        ]
        @matcher = Silicon::Routing::Matcher.new(routes)
      end

      it 'returns nil' do
        result = @matcher.match('/hello-world', 'GET')
        expect(result).to be_nil
      end
    end

    context 'when there is matching route' do
      before :all do
        @route = Silicon::Routing::Route.new(http_verb: 'GET', path: '/hello-world')
        @matcher = Silicon::Routing::Matcher.new([@route])
      end

      it 'returns a match' do
        result = @matcher.match('/hello-world', 'GET')
        expect(result.route).to eql @route
      end
    end

    context 'when path is longer than a similar route' do
      before :all do
        @route = Silicon::Routing::Route.new(http_verb: 'GET', path: '/hello-world')
        @matcher = Silicon::Routing::Matcher.new([@route])
      end

      it 'returns nil' do
        result = @matcher.match('/hello-world/test', 'GET')
        expect(result).to be_nil
      end
    end

    context 'when there is matching route with parameters' do
      before :all do
        @route = Silicon::Routing::Route.new(http_verb: 'DELETE', path: '/post/$id/comments/$comment_id')
        @matcher = Silicon::Routing::Matcher.new([@route])
      end

      it 'returns a match with parameters' do
        result = @matcher.match('/post/6/comments/my-comment', 'DELETE')
        expect(result.route).to eql @route
        expect(result.params['id']).to eql '6'
        expect(result.params['comment_id']).to eql 'my-comment'
      end
    end
  end
end
