# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'docparser/version'

Gem::Specification.new do |spec|
  spec.name          = "DocParser"
  spec.version       = DocParser::VERSION
  spec.authors       = ["Jurriaan Pruis"]
  spec.email         = ["email@jurriaanpruis.nl"]
  spec.description   = %q{DocParser is a Ruby Gem for webscraping}
  spec.summary       = %q{DocParser is a Ruby Gem for webscraping}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
