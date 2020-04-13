# DocParser

[![Gem Version](http://img.shields.io/gem/v/docparser.svg)](http://badge.fury.io/rb/docparser) [![Build Status](http://img.shields.io/travis/jurriaan/docparser.svg)](https://travis-ci.org/jurriaan/docparser) [![Dependency Status](http://img.shields.io/gemnasium/jurriaan/docparser.svg)](https://gemnasium.com/jurriaan/docparser)


DocParser is a web scraping/screen scraping tool.

You can use it to easily scrape information out of HTML documents.

The gem is called [docparser](http://rubygems.org/gems/docparser).
You can find the documentation [here](http://rubydoc.info/github/jurriaan/docparser/).

## Features

- XPath and CSS support through Nokogiri
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

    bundle

Or install it yourself using:

    gem install docparser

## Usage

See [example.rb](https://github.com/jurriaan/docparser/blob/master/example.rb)

## Todo

- Better examples and documentation

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Contributors

- [Jurriaan Pruis](https://github.com/jurriaan)

## Thanks

- [randym](https://github.com/randym) - for providing the [axlsx](https://github.com/randym/axlsx) gem
