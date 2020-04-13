# frozen_string_literal: true

require_relative '../../../test_helper'

describe DocParser::YAMLOutput do
  it 'must create a file' do
    Dir.mktmpdir do |dir|
      filename = File.join(dir, 'test.yml')
      DocParser::YAMLOutput.new(filename: filename)
      File.exist?(filename).must_equal true
    end
  end

  it 'must save the header' do
    Dir.mktmpdir do |dir|
      filename = File.join(dir, 'test.yml')
      output = DocParser::YAMLOutput.new(filename: filename)
      output.header = 'test', 'the', 'header'
      output.close
      open(filename).read.must_equal ''
    end
  end

  it 'must have a header' do
    Dir.mktmpdir do |dir|
      filename = File.join(dir, 'test.yml')
      output = DocParser::YAMLOutput.new(filename: filename)
      lambda do
        output.add_row %w[aap noot mies]
      end.must_raise(DocParser::MissingHeaderException)
    end
  end

  it 'must save some rows' do
    Dir.mktmpdir do |dir|
      filename = File.join(dir, 'test.csv')
      output = DocParser::YAMLOutput.new(filename: filename)
      output.header = 'test', 'the', 'header'
      output.add_row %w[a b c]
      output.add_row %w[aap noot mies"]
      output.add_row %w[aap noot] # testing empty column
      output.close
      open(filename).read.must_equal <<~YAMLEND
        ---
        test: a
        the: b
        header: c
        ---
        test: aap
        the: noot
        header: mies\"
        ---
        test: aap
        the: noot
        header: ''
      YAMLEND
    end
  end

  it 'must give the correct rowcount' do
    Dir.mktmpdir do |dir|
      filename = File.join(dir, 'test.yml')
      output = DocParser::YAMLOutput.new(filename: filename)
      output.header = 'test', 'the', 'header'
      output.rowcount.must_equal 0
      output.add_row %w[aap noot mies]
      output.add_row %w[aap noot mies]
      output.rowcount.must_equal 2
    end
  end
end
