require_relative '../../test_helper'

describe DocParser do
  it 'must have a version' do
    DocParser::VERSION.wont_be_nil
  end

  it 'must have a correct version' do
    DocParser::VERSION.must_match(/^\d+\.\d+\.\d+$/)
  end
end
