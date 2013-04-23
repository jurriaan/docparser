require_relative '../../test_helper'

describe DocParser do
  it "must have a version" do
    DocParser::VERSION.wont_be_nil
  end
end