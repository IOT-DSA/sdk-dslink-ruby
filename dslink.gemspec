$:.unshift File.expand_path("../lib", __FILE__)

require 'ds/version'

Gem::Specification.new do |s|
  s.name        = 'dslink'
  s.version     =  DSLink::VERSION
  s.summary     = 'Ruby SDK for DSLinks'
  s.description = 'SDK to work with DSA Node Protocol'
  s.author      = 'Kerry Gould'
  s.email       = 'k.gould@dglogik.com'
  s.homepage    = 'http://github.com/IOT-DSA/sdk-dslink-ruby'
  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- test/*`.split("\n")
  s.license     = 'MIT'

  s.required_ruby_version = '>= 2.0.0'
  
  s.add_runtime_dependency 'slop', ['= 4.2.0']
  s.add_runtime_dependency 'celluloid', ['= 0.16.0']
  s.add_runtime_dependency 'celluloid-io', ['= 0.16.2']
  s.add_runtime_dependency 'websocket-driver', ['= 0.5.4']

  # s.add_development_dependency 'yard', ['= 0.8.7.6']
  # s.add_development_dependency 'rspec', ['= 3.3.0']
end