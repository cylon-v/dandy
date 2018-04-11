module Dandy
  class TypeLoader
    def initialize(dandy_config)
      @directories = dandy_config[:path][:dependencies]
    end

    def load_types
      types = []
      @directories.each do |directory|
        dir = File.join(directory, '**/*')
        files = Dir.glob(dir).reject {|file_path| File.directory?(file_path)}

        files.each do |file|
          path = File.join(Dir.pwd, file)
          require path
          file_name = File.basename(file).gsub(File.extname(file), '')
          class_name = file_name.split('_').each(&:capitalize!).join('')
          types << {
            class: Object.const_get(class_name),
            path: file.gsub(File.extname(file), '').gsub(directory + '/', '')
          }
        end
      end

      types
    end
  end
end