#
# An example of parsing hackaday.com
# (C) 2013 Jurriaan Pruis
#

require 'docparser'
include DocParser
output = HTMLOutput.new(filename: 'hackaday.html')
output.header = 'Title', 'Author', 'Publication date', 'URL', 'Summary'
urls = (1..20).map { |i| "http://hackaday.com/page/#{i}/" }
parser = Parser.new(files: urls, parallel: false, output: output)
parser.parse! do
  css('#content .post') do |post|
    title_el = post.search('.entry-title a').first
    title = title_el.content
    author = post.search('.post-info .author .fn a').first.content
    published_time = post.search('.post-info .date.published').first.content
    url = title_el.attributes['href']
    summary = post.search('.entry-content').first.content.strip
    add_row title, author, published_time, url, summary
  end
end