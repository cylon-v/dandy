# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dandy/version'

Gem::Specification.new do |spec|
  spec.name          = 'dandy'
  spec.version       = Dandy::VERSION
  spec.authors       = ['Vladimir Kalinkin']
  spec.email         = ['vova.kalinkin@gmail.com']

  spec.summary       = 'Dandy is a minimalistic web API framework.'
  spec.description   = 'The philosophy of Dandy is to provide minimalistic' \
                       ' middleware between your model and API client.'

  spec.homepage      = 'https://github.com/cylon-v/dandy'
  spec.license       = 'MIT'

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'hypo', '~> 0.9.0'
  spec.add_dependency 'rack', '~> 2.0.3'
  spec.add_dependency 'thor', '~> 0.20.0'
  spec.add_dependency 'treetop', '~> 1.6.8'
  spec.add_dependency 'jbuilder', '~> 2.7.0'
  spec.add_dependency 'rack-parser', '~> 0.7.0'
  spec.add_dependency 'terminal-table', '~> 1.8.0'
  spec.add_dependency 'awrence', '~> 1.0.0'
  spec.add_dependency 'plissken', '~> 1.2.0'
  spec.add_dependency 'concurrent-ruby', '~> 1.0.5'

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-mocks', '~> 3.6'
  spec.add_development_dependency  'simplecov', '~> 0.15'
end
