module Silicon
  class ViewBuilder
    def initialize(template, container)
      @template = template
      @container = container
      @variables = template.scan(/@[a-z_][a-zA-Z_0-9]*/).uniq
    end

    def process
      @variables.each do |variable|
        value = @container.resolve(variable.sub('@', '').to_sym)
        instance_variable_set variable, value
      end

      build
    end
  end
end