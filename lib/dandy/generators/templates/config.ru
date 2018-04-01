require 'rack'
require 'rack/cors'
require './app/app'

use Rack::Parser, :content_types => {
  'application/json'  => Proc.new { |body| ::MultiJson.decode body }
}

use Rack::Cors do
  # Setup your CORS policy
end

if ENV['DANDY_ENV'] == 'development' || ENV['DANDY_ENV'] == ''
  use Rack::Reloader
end

run App.new