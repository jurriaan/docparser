require_relative '../../../test_helper'

describe DocParser::JSONOutput do
  before do
    Log4r::Logger['docparser'].level = Log4r::ERROR
  end
  after do
    Log4r::Logger['docparser'].level = Log4r::INFO
  end

  it 'must create a file' do
    Dir.mktmpdir do |dir|
      filename = File.join(dir, 'test.json')
      DocParser::JSONOutput.new(filename: filename)
      File.exists?(filename).must_equal true
    end
  end

  it 'must save the header' do
    Dir.mktmpdir do |dir|
      filename = File.join(dir, 'test.json')
      output = DocParser::JSONOutput.new(filename: filename)
      output.header = 'test', 'the', 'header'
      output.close
      open(filename).read.must_equal '[]'
    end
  end

  it 'must have a header' do
    Dir.mktmpdir do |dir|
      filename = File.join(dir, 'test.json')
      output = DocParser::JSONOutput.new(filename: filename)
      -> do
        output.add_row ['aap', 'noot', 'mies']
      end.must_raise(DocParser::MissingHeaderException)
    end
  end

  it 'must save some rows' do
    Dir.mktmpdir do |dir|
      filename = File.join(dir, 'test.json')
      output = DocParser::JSONOutput.new(filename: filename)
      output.header = 'test', 'the', 'header'
      output.add_row ['a', 'b', 'c']
      output.add_row ['aap', 'noot', 'mies"']
      output.add_row ['aap', 'noot'] # testing empty column
      output.close
      open(filename).read.must_equal '[{"test":"a","the":"b","header":"c"}'\
      ',{"test":"aap","the":"noot","header":"mies\""}'\
      ',{"test":"aap","the":"noot","header":""}]'
    end
  end

  it 'must give the correct rowcount' do
    Dir.mktmpdir do |dir|
      filename = File.join(dir, 'test.json')
      output = DocParser::JSONOutput.new(filename: filename)
      output.header = 'test', 'the', 'header'
      output.rowcount.must_equal 0
      output.add_row ['aap', 'noot', 'mies']
      output.add_row ['aap', 'noot', 'mies']
      output.rowcount.must_equal 2
    end
  end
end