require_relative '../../../test_helper'
require 'stringio'
describe DocParser::ScreenOutput do
  before do
    Log4r::Logger['docparser'].level = Log4r::ERROR
  end
  after do
    Log4r::Logger['docparser'].level = Log4r::INFO
  end

  it 'should not create a file' do
    Dir.mktmpdir do |dir|
      filename = File.join(dir, '*')
      DocParser::ScreenOutput.new
      Dir[filename].must_be_empty
    end
  end

  it 'must give the correct rowcount' do
    output = DocParser::ScreenOutput.new
    output.header = 'test', 'the', 'header'
    output.rowcount.must_equal 0
    output.add_row %w(aap noot mies)
    output.add_row %w(aap noot mies)
    output.rowcount.must_equal 2
  end

  it 'must have a header' do
    output = DocParser::ScreenOutput.new
    lambda do
      output.add_row %w(aap noot mies)
    end.must_raise(DocParser::MissingHeaderException)
  end

  it 'must output the data after close' do
    $out = StringIO.new
    output = Class.new DocParser::ScreenOutput do
      def page(*args, &p)
        args << p
        args.compact!
        page_to $out, args
      end
    end.new
    output.header = 'test', 'the', 'header'
    output.add_row ['aap1' , '', 'mies']
    output.add_row %w(aap2 mies1)
    output.close
    out = $out.string
    out.must_include 'header'
    out.must_include 'aap1'
    out.must_include 'mies1'
    out.must_include 'mies'
  end
end
