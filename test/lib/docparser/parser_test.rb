require_relative '../../test_helper'
describe DocParser::Parser do
  before do
    SimpleCov.at_exit { }
  end

  after do
    SimpleCov.at_exit do
      SimpleCov.result.format!
    end
    Log4r::Logger['docparser'].level = Log4r::INFO
  end

  it 'should initialize correctly' do
    parser = DocParser::Parser.new(quiet: true)
    parser.must_be_instance_of DocParser::Parser
  end

  it 'should define a new logger' do
    DocParser::Parser.new(quiet: true)
    logger = Log4r::Logger['docparser::parser']
    logger.wont_be_nil
    logger.must_be_instance_of Log4r::Logger
  end

  it 'should set logger level depending on the quiet setting' do
    parser = DocParser::Parser.new(quiet: true)
    logger = Log4r::Logger['docparser']
    old_output = logger.outputters.pop
    logger.level.must_equal Log4r::ERROR
    parser = DocParser::Parser.new(quiet: false)
    logger.level.must_equal Log4r::INFO
    parser = DocParser::Parser.new
    logger.level.must_equal Log4r::INFO
    logger.outputters.push old_output
  end

  it 'should only process the files in range' do
    files = (0..20).map { |i| "file_#{i}" }
    parser = DocParser::Parser.new(quiet: true,
                                   files: files,
                                   range: 0...10)
    parser.files.length.must_equal 10
    parser.files.must_equal files[0...10]
  end

  it 'should set the correct number of processes' do
    parser = DocParser::Parser.new(quiet: true)
    default = Parallel.processor_count + 1
    parser.num_processes.must_equal(default)
    parser = DocParser::Parser.new(quiet: true,
                                   num_processes: 4,
                                   parallel: false)
    parser.num_processes.must_equal(1)
    parser = DocParser::Parser.new(quiet: true,
                                   num_processes: 4,
                                   parallel: true)
    parser.num_processes.must_equal(4)
  end

  it 'should set the correct encoding' do
    parser = DocParser::Parser.new(quiet: true)
    parser.encoding.must_equal 'utf-8'
    parser = DocParser::Parser.new(quiet: true, encoding: 'iso-8859-1')
    parser.encoding.must_equal 'iso-8859-1'
    file = Tempfile.new('foo')
    file.write('<html />')
    file.close
    parser = DocParser::Parser.new(quiet: true, encoding: 'iso-8859-1',
                                   files: [file.path],
                                   parallel: false)
    parser.parse! do
      $encoding = encoding
    end
    $encoding.must_equal 'iso-8859-1'
  end

  it 'should give an Exception if output is not supported' do
    lambda do
      DocParser::Parser.new(quiet: true, output: 1)
    end.must_raise(ArgumentError)
  end

  it 'should support one output' do
    mock_output = SimpleMock.new DocParser::NilOutput.new
    mock_output.expect :close, nil
    mock_output.expect :is_a?, true, [DocParser::Output]
    testfile = File.join($SUPPORT_DIR, 'test_html.html')
    parser = DocParser::Parser.new(quiet: true, encoding: 'iso-8859-1',
                                   files: [testfile],
                                   parallel: false,
                                   output: mock_output)
    parser.parse! do
      # do nothing
    end
    mock_output.verify.must_equal true
  end

  it 'should support multiple outputs' do
    mock_output = SimpleMock.new DocParser::NilOutput.new
    mock_output.expect :close, nil
    mock_output.expect :is_a?, true, [DocParser::Output]
    mock_output2 = SimpleMock.new DocParser::NilOutput.new
    mock_output2.expect :close, nil
    mock_output2.expect :is_a?, true, [DocParser::Output]
    testfile = File.join($SUPPORT_DIR, 'test_html.html')
    parser = DocParser::Parser.new(quiet: true, encoding: 'iso-8859-1',
                                   files: [testfile],
                                   parallel: false,
                                   output: [mock_output, mock_output2])
    parser.parse! do
      # do nothing
    end
    parser.outputs.length.must_equal 2
    mock_output.verify.must_equal true
    mock_output2.verify.must_equal true
  end

  it 'should write to the outputs' do
    mock_output = SimpleMock.new DocParser::NilOutput.new
    mock_output.expect :close, nil
    mock_output.expect :is_a?, true, [DocParser::Output]
    mock_output.expect :add_row, true, [['output 0']]
    mock_output2 = SimpleMock.new DocParser::NilOutput.new
    mock_output2.expect :close, nil
    mock_output2.expect :is_a?, true, [DocParser::Output]
    mock_output2.expect :add_row, true, [['output 1']]
    testfile = File.join($SUPPORT_DIR, 'test_html.html')
    parser = DocParser::Parser.new(quiet: true, encoding: 'iso-8859-1',
                                   files: [testfile],
                                   parallel: false,
                                   output: [mock_output, mock_output2])
    parser.parse! do
      add_row 'output 0', output: 0
      add_row 'output 1', output: 1
    end
    parser.outputs.length.must_equal 2
    mock_output.verify.must_equal true
    mock_output2.verify.must_equal true
  end

  it 'should write to the outputs directly' do
    mock_output = SimpleMock.new DocParser::NilOutput.new
    mock_output.expect :close, nil
    mock_output.expect :is_a?, true, [DocParser::Output]
    mock_output.expect :add_row, true, [['output 0']]
    mock_output2 = SimpleMock.new DocParser::NilOutput.new
    mock_output2.expect :close, nil
    mock_output2.expect :is_a?, true, [DocParser::Output]
    mock_output2.expect :add_row, true, [['output 1']]
    testfile = File.join($SUPPORT_DIR, 'test_html.html')
    parser = DocParser::Parser.new(quiet: true, encoding: 'iso-8859-1',
                                   files: [testfile],
                                   parallel: false,
                                   output: [mock_output, mock_output2])
    parser.parse! do
      add_row 'output 1', output: mock_output2
      add_row 'output 0', output: mock_output
    end
    parser.outputs.length.must_equal 2
    mock_output.verify.must_equal true
    mock_output2.verify.must_equal true
  end

  it 'should support parallel processing' do
    mock_output = SimpleMock.new DocParser::NilOutput.new
    mock_output.expect :close, nil
    mock_output.expect :is_a?, true, [DocParser::Output]
    mock_output.expect :add_row, nil, [['Test HTML']]
    mock_output.expect :add_row, nil, [['Test HTML']]
    testfile = File.join($SUPPORT_DIR, 'test_html.html')
    DocParser::Kernel = SimpleMock.new Kernel

    parser = DocParser::Parser.new(quiet: true, encoding: 'iso-8859-1',
                                   files: [testfile, testfile],
                                   parallel: true,
                                   output: mock_output)
    # :nocov: #
    trace = TracePoint.trace(:c_call) do |tp|
      if tp.method_id == :fork
        $method_id = tp.method_id
        tp.disable
      end
    end

    trace.enable do
      parser.parse! do
        add_row title
      end
    end
    # :nocov: #
    $method_id.must_equal :fork
    mock_output.verify.must_equal true
  end
end