require 'thor'

module Silicon
  class CLI < Thor
    include Thor::Actions

    def self.source_root
      File.dirname(__FILE__)
    end

    desc 'new NAME', 'create new Silicon application'
    def new(name)
      copy_file 'templates/app.rb', "#{name}/app/app.rb"
      copy_file 'templates/app.routes', "#{name}/app/app.routes"
      copy_file 'templates/silicon.yml', "#{name}/silicon.yml"
      copy_file 'templates/config.ru', "#{name}/config.ru"
      copy_file 'templates/views/show_welcome.json.jbuilder', "#{name}/app/views/show_welcome.json.jbuilder"
      copy_file 'templates/actions/common/handle_errors.rb', "#{name}/app/actions/common/handle_errors.rb"
      template 'templates/actions/welcome.tt', "#{name}/app/actions/welcome.rb", {app_name: name}
    end
  end
end

