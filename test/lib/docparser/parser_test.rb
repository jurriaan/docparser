require_relative '../../test_helper'
describe DocParser do
  it "should initialize correctly" do
    parser = DocParser::Parser.new(quiet: true)
    parser.must_be_instance_of  DocParser::Parser
  end

  it "should define a new logger" do
    parser = DocParser::Parser.new(quiet: true)
    logger = Log4r::Logger['docparser::parser']
    logger.wont_be_nil
    logger.must_be_instance_of Log4r::Logger
  end

  it "should set logger level depending on the quiet setting" do
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

  it "should only process the files in range" do
    parser = DocParser::Parser.new(quiet: true, files: ['file'] * 20, range: 0...10)
    parser.files.length.must_equal 10
  end

end