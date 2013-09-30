lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'docparser/version'

Gem::Specification.new do |spec|
  spec.name          = 'docparser'
  spec.version       = DocParser::VERSION
  spec.authors       = ['Jurriaan Pruis']
  spec.email         = ['email@jurriaanpruis.nl']
  spec.description   = 'DocParser is a Ruby Gem for webscraping'
  spec.summary       = 'DocParser is a Ruby Gem for webscraping'
  spec.homepage      = 'https://github.com/jurriaan/docparser'
  spec.license       = 'MIT'
  spec.platform      = Gem::Platform::RUBY

  spec.files         = `git ls-files`.split($RS)
  spec.executables   = spec.files.grep(/^bin\//) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/^(test|spec|features)\//)
  spec.require_paths = ['lib']
  spec.extra_rdoc_files = ['README.md', 'LICENSE']

  spec.add_runtime_dependency 'nokogiri', '~> 1.6.0'
  spec.add_runtime_dependency 'parallel', '~> 0.8.4'
  spec.add_runtime_dependency 'axlsx', '~> 2.0.1'
  spec.add_runtime_dependency 'terminal-table', '~> 1.4.5'
  spec.add_runtime_dependency 'pageme', '~> 0.0.3'
  spec.add_runtime_dependency 'log4r', '~> 1.1.10'

  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'redcarpet'
  spec.add_development_dependency 'github-markup'
  spec.required_ruby_version = '>= 2.0.0'
end
