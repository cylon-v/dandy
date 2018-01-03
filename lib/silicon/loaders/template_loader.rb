module Silicon
  class TemplateLoader
    def initialize(silicon_config)
      @directory = File.join(silicon_config[:path][:views], '**/*')
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