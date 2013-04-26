# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'docparser/version'

Gem::Specification.new do |spec|
  spec.name          = "docparser"
  spec.version       = DocParser::VERSION
  spec.authors       = ["Jurriaan Pruis"]
  spec.email         = ["email@jurriaanpruis.nl"]
  spec.description   = %q{DocParser is a Ruby Gem for webscraping}
  spec.summary       = %q{DocParser is a Ruby Gem for webscraping}
  spec.homepage      = "https://github.com/jurriaan/docparser"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'nokogiri', '~> 1.5.9'
  spec.add_runtime_dependency 'parallel', '~> 0.6.4'
  spec.add_runtime_dependency 'axlsx', '~> 1.3.6'
  spec.add_runtime_dependency 'terminal-table', '~> 1.4.5'
  spec.add_runtime_dependency 'pageme', '~> 0.0.3'
  spec.add_runtime_dependency 'json', '~> 1.7.7'
  spec.add_runtime_dependency 'log4r', '~> 1.1.10'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
