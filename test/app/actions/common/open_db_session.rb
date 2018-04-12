require 'sequel'
require 'jet_set'
require 'logger'

class OpenDbSession
  def initialize(container, dandy_config, dandy_env)
    @container = container
    @config = dandy_config
    @dandy_env = dandy_env
  end

  def call
    # Instead of :url you can specify required Sequel connection parameters in dandy.yml.
    # Additional details about Sequel connection configuration
    # see at http://sequel.jeremyevans.net/rdoc/files/doc/opening_databases_rdoc.html
    connection = Sequel.connect(@config[:db][:url])

    if @dandy_env == 'development'
      connection.loggers << Logger.new($stdout)
    end

    JetSet::open_session(connection, :dandy_request)
  end
end