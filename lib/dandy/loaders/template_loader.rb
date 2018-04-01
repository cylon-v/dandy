module Dandy
  class TemplateLoader
    def initialize(dandy_config)
      @directory = File.join(dandy_config[:path][:views], '**/*')
    end

    def load_templates
      result = {}

      files = Dir.glob(@directory).reject {|file_path| File.directory? file_path}
      files.each do |file|
        path = File.join Dir.pwd, file
        content = File.read(path)
        result[file] = content
      end

      result
    end
  end
end