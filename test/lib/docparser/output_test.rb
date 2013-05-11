require_relative '../../test_helper'

describe DocParser::Output do
  before do
    Log4r::Logger['docparser'].level = Log4r::ERROR
  end
  after do
    Log4r::Logger['docparser'].level = Log4r::INFO
  end

  it 'must create a file' do
    Dir.mktmpdir do |dir|
      filename = File.join(dir, 'test.csv')
      DocParser::Output.new(filename: filename)
      File.exists?(filename).must_equal true
    end
  end

  it 'must call the header callback' do
    Dir.mktmpdir do |dir|
      filename = File.join(dir, 'test.csv')
      output = DocParser::Output.new(filename: filename)
      # :nocov: #
      trace = TracePoint.trace(:call) do |tp|
        if tp.method_id == :header
          $method_id = tp.method_id
          tp.disable
        end
      end
      # :nocov: #
      trace.enable do
        output.header = 'test', 'the', 'header'
      end
      header = output.instance_variable_get(:@header)
      header.must_equal %w(test the header)
      $method_id.must_equal :header
    end
  end

  it 'must call the open_file callback' do
    Dir.mktmpdir do |dir|
      filename = File.join(dir, 'test.csv')
      # :nocov: #
      trace = TracePoint.trace(:call) do |tp|
        if tp.method_id == :open_file
          $method_id = tp.method_id
          tp.disable
        end
      end
      # :nocov: #
      trace.enable do
        DocParser::Output.new(filename: filename)
      end
      $method_id.must_equal :open_file
    end
  end

  it 'must call the footer callback' do
    Dir.mktmpdir do |dir|
      filename = File.join(dir, 'test.csv')
      # :nocov: #
      trace = TracePoint.trace(:call) do |tp|
        if tp.method_id == :footer
          $method_id = tp.method_id
          tp.disable
        end
      end
      # :nocov: #
      output = DocParser::Output.new(filename: filename)
      trace.enable do
        output.close
      end
      $method_id.must_equal :footer
    end
  end

  it 'should raise a NotImplementedError on write_row' do
    Dir.mktmpdir do |dir|
      filename = File.join(dir, 'test.csv')
      output = DocParser::Output.new(filename: filename)
      -> { output.write_row([]) }.must_raise(NotImplementedError)
    end
  end
end