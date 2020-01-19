module Dandy
  class Response
    def self.format(result, headers)
      if headers['Keys-Format'] == 'camel' && result
        result = result.to_camelback_keys
      end

      JSON.generate(result)
    end
  end
end