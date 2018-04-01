module Dandy
  module Routing
    class FileReader
      def initialize(dandy_config)
        @config = dandy_config
      end

      def read
        path = File.join('./', @config[:path][:routes])
        content = File.read(path)

        # use '^' instead spaces and tabs
        raw_content = content.gsub(/\t/, '  ')
                        .gsub('  ', '^')
                        .gsub(' ', '')

        ###Hack:
        # grammar problem - can't simply match '-' character in route path when '->' present.
        # Will be resolved later. Replace '->', '<-' with '*>', '<*' for a while for syntax parser.
        ###
        raw_content = raw_content.gsub('->', '*>').gsub('<-', '<*')

        raw_content.gsub!("\n", ';') + ';'
      end
    end
  end
end