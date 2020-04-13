# frozen_string_literal: true

require_relative '../../../test_helper'

describe DocParser::HTMLOutput do
  it 'must create a file' do
    Dir.mktmpdir do |dir|
      filename = File.join(dir, 'test.html')
      DocParser::HTMLOutput.new(filename: filename)
      File.exist?(filename).must_equal true
    end
  end

  it 'must save the header' do
    Dir.mktmpdir do |dir|
      filename = File.join(dir, 'test.html')
      output = DocParser::HTMLOutput.new(filename: filename)
      output.header = 'test', 'the', 'header'
      output.close
      open(filename).read.must_include '<thead><tr><th>test</th><th>the</th>
      <th>header</th></tr></thead>'.gsub(/\s+/, '')
    end
  end

  it 'must save some rows' do
    Dir.mktmpdir do |dir|
      filename = File.join(dir, 'test.html')
      output = DocParser::HTMLOutput.new(filename: filename)
      output.add_row %w[aap noot mies]
      output.add_row ['aap', 'noot', 'mies;']
      output.close
      html = open(filename).read
      html.must_include 'tbody'
      html.must_include '<tr><td>aap</td><td>noot</td><td>mies</td></tr>'
      html.must_include '<tr><td>aap</td><td>noot</td><td>mies;</td></tr>'
    end
  end

  it 'must give the correct rowcount' do
    Dir.mktmpdir do |dir|
      filename = File.join(dir, 'test.html')
      output = DocParser::HTMLOutput.new(filename: filename)
      output.header = 'test', 'the', 'header'
      output.rowcount.must_equal 0
      output.add_row %w[aap noot mies]
      output.add_row %w[aap noot mies]
      output.rowcount.must_equal 2
      output.close
      open(filename).read.must_include('<p>2 rows</p>')
    end
  end
end
