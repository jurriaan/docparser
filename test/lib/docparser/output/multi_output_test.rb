require_relative '../../../test_helper'

describe DocParser::MultiOutput do
  before do
    Log4r::Logger['docparser'].level = Log4r::ERROR
  end
  after do
    Log4r::Logger['docparser'].level = Log4r::INFO
  end

  it 'must create files' do
    Dir.mktmpdir do |dir|
      filename = File.join(dir, 'test')
      DocParser::MultiOutput.new(filename: filename)

      File.exists?(filename).must_equal false
      ['.csv', '.html', '.yml', '.xlsx', '.json'].each do |ext|
        File.exists?(filename + ext).must_equal true
      end
    end
  end

  it 'must save the header' do
    Dir.mktmpdir do |dir|
      filename = File.join(dir, 'test')
      output = DocParser::MultiOutput.new(filename: filename)
      output.header = 'test', 'the', 'header'
      output.close
      open(filename + '.yml').read.must_equal ''
      open(filename + '.csv').read.must_equal "test;the;header\n"
    end
  end

  it 'must have a header' do
    Dir.mktmpdir do |dir|
      filename = File.join(dir, 'test')
      output = DocParser::MultiOutput.new(filename: filename)
      -> do
        output.add_row ['aap', 'noot', 'mies']
      end.must_raise(DocParser::MissingHeaderException)
    end
  end

  it 'must give the correct rowcount' do
    Dir.mktmpdir do |dir|
      filename = File.join(dir, 'test')
      output = DocParser::MultiOutput.new(filename: filename)
      output.header = 'test', 'the', 'header'
      output.rowcount.must_equal 0
      output.add_row ['aap', 'noot', 'mies']
      output.add_row ['aap', 'noot', 'mies']
      output.rowcount.must_equal 2
    end
  end

  it 'must delegate methods' do
    Dir.mktmpdir do |dir|
      filename = File.join(dir, 'test')
      output = DocParser::MultiOutput.new(filename: filename)
      methods = [:add_row, :header=, :close]
      outputs = output.instance_variable_get(:@outputs)
      outputs.map! do |o|
        SimpleMock.new o
      end
      output.instance_variable_set(:@outputs, outputs)
      methods.each do |method_name|
        method = output.method(method_name)
        arity = method.arity
        outputs.map do |o|
          o.expect(method_name, nil, [nil] * arity)
        end
        output.send(method_name, *([nil] * arity))
      end
      outputs.map do |o|
        o.verify.must_equal true
      end
    end
  end

end