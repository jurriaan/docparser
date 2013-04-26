# DocParser

[![Gem Version](https://badge.fury.io/rb/docparser.png)](http://badge.fury.io/rb/docparser) [![Build Status](https://travis-ci.org/jurriaan/docparser.png?branch=master)](https://travis-ci.org/jurriaan/docparser) [![Dependency Status](https://gemnasium.com/jurriaan/docparser.png)](https://gemnasium.com/jurriaan/docparser) [![Coverage Status](https://coveralls.io/repos/jurriaan/docparser/badge.png?branch=master)](https://coveralls.io/r/jurriaan/docparser)


DocParser is a web scraping/screen scraping tool.

You can use it to easily scrape web sites.

The gem is called [docparser](http://rubygems.org/gems/docparser).
You can find the documentation [here](http://rubydoc.info/github/jurriaan/docparser/).

## Features

- XPath and CSS support through Nokogiri
- Support for loading of URLs throug open-uri
- Support for parallel processing of the documents
- 6 Output formats:
  * CSV
  * XLSX
  * HTML
  * YAML
  * JSON
  * Screen (for debugging and development)
  * And more! (easy to extend)

## Installation

Add this line to your application's Gemfile:

    gem 'docparser'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install docparser

## Usage

See [example.rb](https://github.com/jurriaan/docparser/blob/master/example.rb)

## Todo

- Tests
- Better examples

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Contributors

- [Jurriaan Pruis](https://github.com/jurriaan)
