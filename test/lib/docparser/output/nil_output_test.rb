# frozen_string_literal: true

require_relative '../../../test_helper'

describe DocParser::NilOutput do
  it 'should not create a file' do
    Dir.mktmpdir do |dir|
      filename = File.join(dir, '*')
      DocParser::NilOutput.new
      Dir[filename].must_be_empty
    end
  end

  it 'must give the correct rowcount' do
    output = DocParser::NilOutput.new
    output.header = 'test', 'the', 'header'
    output.rowcount.must_equal 0
    output.add_row %w[aap noot mies]
    output.add_row %w[aap noot mies]
    output.rowcount.must_equal 0
  end
end
