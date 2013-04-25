#
# An example of parsing hackaday.com
# (C) 2013 Jurriaan Pruis
#
$LOAD_PATH.unshift __dir__
require File.expand_path('lib/docparser.rb', __dir__)
require 'tmpdir'

include DocParser
output = MultiOutput.new(filename: 'hackaday')
output.header = 'Title', 'Author', 'Publication date', 'URL', 'Summary'
files = Dir[File.join(__dir__, 'test/support/hackaday/*.html')]
parser = Parser.new(files: files, parallel: false, output: output)
parser.parse! do
  css('#content .post') do |post|
    title_el = post.search('.entry-title a').first
    title = title_el.content
    author = post.search('.post-info .author .fn a').first.content
    published_time = post.search('.post-info .date.published').first.content
    url = title_el.attributes['href'].value
    summary = post.search('.entry-content').first.content.strip
    add_row title, author, published_time, url, summary
  end
end