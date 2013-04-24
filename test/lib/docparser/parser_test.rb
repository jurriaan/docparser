require_relative '../../test_helper'
describe DocParser::Parser do
  after do
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
    parser = DocParser::Parser.new()
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
                                   output: DocParser::NilOutput.new,
                                   files: [file.path],
                                   parallel: false)
    parser.parse! do
      $encoding = self.encoding
    end
    $encoding.must_equal 'iso-8859-1'
  end
end