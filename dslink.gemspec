$:.push File.expand_path("../lib", __FILE__)

require 'bundler'
require 'dslink/version'

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

  # s.add_development_dependency 'rake'
  # s.add_development_dependency 'minitest', '~> 5.0.0'
end