require 'rack'
require 'rack/cors'
require './app/app'

use Rack::Parser, :content_types => {
  'application/json'  => Proc.new { |body| ::MultiJson.decode body }
}

use Rack::Cors do
  # Setup your CORS policy
end

if ENV['SILICON_ENV'] == 'development' || ENV['SILICON_ENV'] == ''
  use Rack::Reloader
end

run App.new