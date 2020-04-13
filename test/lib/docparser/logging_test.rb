# frozen_string_literal: true

require_relative '../../test_helper'

describe DocParser do
  it 'should have a valid logger' do
    logger = Log4r::Logger['docparser']
    logger.wont_be_nil
    logger.must_be_instance_of Log4r::Logger
  end

  it 'must have the correct loglevel by default' do
    Log4r::Logger['docparser'].level.must_equal Log4r::INFO
  end

  it 'should log to the correct output' do
    outputters = Log4r::Logger['docparser'].outputters
    outputters.length.must_equal 1
    outputters.first.must_be_instance_of Log4r::StdoutOutputter
  end
end
