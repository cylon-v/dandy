require 'silicon/routing/route'

module Silicon
  module Routing
    class Builder
      def initialize
        @parsed_items = []
        @route_params = []
        @current_parent = nil
        @prev_route = nil
      end

      def build(sections)
        result = []

        node = sections.node
        restore_hierarchy(node, nil,node.to_hash)

        @route_params.each do |route|
          if route[:actions]
            route[:actions].each do |action|
              result << Route.new({
                path: restore_path(route).gsub('$', '/$'),
                params: restore_params(route).map{|p| p.sub('$', '')},
                http_verb: action[:http_verb],
                view: action[:view],
                http_status: action[:http_status],
                catch: sections.catch.command,
                commands: restore_callbacks(route, :before) + action[:commands] + restore_callbacks(route, :after)
              })
            end
          end
        end

        result
      end

      private

      def restore_hierarchy(node, prev_route, current_parent)
        route = node.to_hash

        if route[:level] == current_parent[:level]
          route[:parent] = current_parent[:parent]
          parent = route
        elsif route[:level] > prev_route[:level]
          route[:parent] = prev_route
          parent = prev_route
        else
          route[:parent] = current_parent
          parent = current_parent
        end

        @route_params << route
        @prev_route = route

        if node.my_nodes
          node.my_nodes.each {|n| restore_hierarchy(n, route, parent)}
        end
      end

      def restore_path(route)
        path = (route[:route][:path] || route[:route][:parameter] || '')
        if route[:parent]
          restore_path(route[:parent]) + path
        else
          path
        end
      end

      def restore_params(route)
        if route[:route][:parameter]
          param = [route[:route][:parameter]]
        else
          param = []
        end

        if route[:parent]
          restore_params(route[:parent]) + param
        else
          param
        end
      end

      def restore_callbacks(route, type)
        before = route[type]

        if route[:parent]
          restore_callbacks(route[:parent], type) + before
        else
          before
        end
      end
    end
  end
end