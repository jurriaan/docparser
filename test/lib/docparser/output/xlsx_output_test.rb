require_relative '../../../test_helper'

describe DocParser::XLSXOutput do
  before do
    Log4r::Logger['docparser'].level = Log4r::ERROR
  end
  after do
    Log4r::Logger['docparser'].level = Log4r::INFO
  end

  it 'must create a file' do
    Dir.mktmpdir do |dir|
      filename = File.join(dir, 'test.xlsx')
      DocParser::XLSXOutput.new(filename: filename)
      File.exist?(filename).must_equal true
    end
  end

  it 'must save the header' do
    Dir.mktmpdir do |dir|
      filename = File.join(dir, 'test.xlsx')
      output = DocParser::XLSXOutput.new(filename: filename)
      output.header = 'test', 'the', 'header'
      output.close
      sheet = output.instance_variable_get(:@sheet)
      sheet.rows.length.must_equal(1)
    end
  end

  it 'must save some rows' do
    Dir.mktmpdir do |dir|
      filename = File.join(dir, 'test.xlsx')
      output = DocParser::XLSXOutput.new(filename: filename)
      output.add_row %w(aap noot mies)
      output.add_row ['aap', 'noot', 'mies;']
      output.close
      sheet = output.instance_variable_get(:@sheet)
      sheet.rows.length.must_equal(2)
    end
  end

  it 'must give the correct rowcount' do
    Dir.mktmpdir do |dir|
      filename = File.join(dir, 'test.xlsx')
      output = DocParser::XLSXOutput.new(filename: filename)
      output.header = 'test', 'the', 'header'
      output.rowcount.must_equal 0
      output.add_row %w(aap noot mies)
      output.add_row %w(aap noot mies)
      output.rowcount.must_equal 2
    end
  end
end
