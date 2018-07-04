require 'thor'
require 'terminal-table'

module Dandy
  class CLI < Thor
    include Thor::Actions

    def self.source_root
      File.dirname(__FILE__)
    end

    desc 'new NAME', 'Create new Dandy application'
    method_options :jet_set => :boolean
    def new(name)
      copy_file 'templates/.gitignore', "#{name}/.gitignore"

      if options[:jet_set]
        copy_file 'templates/app/app_jet_set.rb', "#{name}/app/app.rb"
        copy_file 'templates/Gemfile_jet_set', "#{name}/Gemfile"
        copy_file 'templates/db/mapping.rb', "#{name}/db/mapping.rb"
        copy_file 'templates/actions/common/open_db_session.rb', "#{name}/app/actions/common/open_db_session.rb"
        copy_file 'templates/actions/common/handle_errors_jet_set.rb', "#{name}/app/actions/common/handle_errors.rb"
      else
        copy_file 'templates/app/app.rb', "#{name}/app/app.rb"
        copy_file 'templates/Gemfile', "#{name}/Gemfile"
        copy_file 'templates/actions/common/handle_errors.rb', "#{name}/app/actions/common/handle_errors.rb"
      end

      copy_file 'templates/app/app.routes', "#{name}/app/app.routes"
      copy_file 'templates/dandy.yml', "#{name}/dandy.yml"
      copy_file 'templates/config.ru', "#{name}/config.ru"
      copy_file 'templates/views/show_welcome.json.jbuilder', "#{name}/app/views/show_welcome.json.jbuilder"
      template 'templates/actions/welcome.tt', "#{name}/app/actions/welcome.rb", {app_name: name}

      if options[:jet_set]
        insert_into_file "#{name}/app/app.routes", "        :before -> common/open_db_session\n", :after => ".->\n"
      end

      inside name do
        run 'bundle'
      end
    end

    desc 'routes', 'Show Dandy application routes'
    def routes
      require './app/app'
      app = App.new

      headings = ['HTTP Verb', 'Path', 'Action Chain']
      rows = app.routes.map do |route|
        indent = ''
        commands = []
        route.commands.each_with_index do |c, index|
          indent += '  ' if c.sequential? && index > 0

          prefix = '->' if c.sequential?
          prefix = '=>' if c.parallel?
          prefix = '=*' if c.async?

          commands << "#{indent} #{prefix} #{c.name}"
        end


        commands = commands.join("\n")
        [route.http_verb, route.path, commands]
      end

      table = Terminal::Table.new(headings: headings, rows: rows)
      table.style = {all_separators: true}
      puts table
    end
  end
end

