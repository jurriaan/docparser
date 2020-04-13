# frozen_string_literal: true

require_relative '../../test_helper'

describe DocParser::Document do
  before do
    $output = DocParser::NilOutput.new
    @parser = Class.new do
      define_method(:outputs) { [$output] }
    end.new
    @test_doc_path = File.join($SUPPORT_DIR, 'test_html.html')
    @test_doc = DocParser::Document.new(filename: @test_doc_path,
                                        parser: @parser)
  end

  it 'should read HTML contents' do
    file = File.join($SUPPORT_DIR, 'test_html.html')
    doc = DocParser::Document.new(filename: file, parser: @parser)
    doc.doc.must_be_instance_of Nokogiri::HTML::Document
    doc.html.must_equal(open(file).read)
  end

  it 'should read XML contents' do
    file = File.join($SUPPORT_DIR, 'test_xml.xml')
    doc = DocParser::Document.new(filename: file, parser: @parser)
    doc.doc.must_be_instance_of Nokogiri::XML::Document
    doc.html.must_equal(open(file).read)
    doc.xpath_content('xmltest > title').must_equal('Test XML')
    doc.xpath_content('xmltest > test').must_equal('Character Data')
  end

  it 'should use the correct encoding' do
    file = File.join($SUPPORT_DIR, 'test_encoding.html')
    file2 = File.join($SUPPORT_DIR, 'test_encoding2.html')
    doc = DocParser::Document.new(filename: file, parser: @parser)
    doc2 = DocParser::Document.new(filename: file2,
                                   parser: @parser,
                                   encoding: 'iso-8859-1')
    doc.html.must_equal(doc2.html)
    doc.css_content('#encoding').must_equal(doc2.css_content('#encoding'))
  end

  it 'should specify filename and encoding in #inspect' do
    @test_doc.inspect.must_include(@test_doc.filename)
    @test_doc.inspect.must_include(@test_doc.encoding)
  end

  it 'should get the title of a document' do
    @test_doc.title.must_equal('Test HTML')
  end

  it 'should store the path to the document' do
    @test_doc.filename.must_equal(@test_doc_path)
  end

  it 'should be possible to use css queries' do
    css = 'article > h1 + p'
    css_content = @test_doc.css_content(css)
    css_element = @test_doc.elements(css)
    css_content.must_equal('Great article it is')
    css_content.must_equal(css_element.first.content)
  end

  it 'should be possible to use xpath queries' do
    xpath = '//li/ancestor::article/h1'
    xpath_content = @test_doc.element_content(xpath)
    xpath_element = @test_doc.elements(xpath)
    xpath_content.must_equal('This is an article')
    xpath_content.must_equal(xpath_element.first.content)
  end

  it 'should be possible to use regular expressions' do
    regex = @test_doc.regexp(/\<h1\>([^\<])*/)
    regex.must_equal(@test_doc.html.match(/\<h1\>([^\<])*/))
  end

  it 'should be possible to use blocks on query methods' do
    array = []
    @test_doc.css('p') do |element|
      array << element.content
    end
    array.last.must_equal('This is the last paragraph')
    array2 = []
    @test_doc.xpath('//p') do |element|
      array2 << element.content
    end
    array2.must_equal(array)
    array2 = []
    @test_doc.each_element('//p') do |element|
      array2 << element.content
    end
    array2.must_equal(array)
  end

  it 'should warn when providing an empty file' do
    file = Tempfile.new('empty')
    file.write('')
    file.close

    open(file.path).read.empty?.must_equal true
    err = StringIO.new

    DocParser::Document.new(filename: file.path,
                            parser: @parser,
                            logger: Logger.new(err))

    err.string.must_include "#{file.path} is empty"
  end

  it 'should add the row to the results' do
    @test_doc.add_row ['test']
    @test_doc.add_row 'test', 'test2'
    @test_doc.results.must_equal [[%w[test], %w[test test2]]]
  end

  it 'should be possible to not use outputs' do
    parser = Class.new do
      define_method(:outputs) { [] }
    end.new
    test_doc = DocParser::Document.new(filename: @test_doc_path,
                                       parser: parser)
    test_doc.html.must_include('Test HTML')
  end

  it 'should be possible to specify outputs directly' do
    @test_doc.add_row ['test!'], output: $output
    @test_doc.results.must_equal [[['test!']]]
  end

  it 'should be possible to use multiple outputs' do
    output = DocParser::NilOutput.new
    output2 = DocParser::NilOutput.new
    parser = Class.new do
      define_method(:outputs) { [output, output2] }
    end.new
    test_doc = DocParser::Document.new(filename: @test_doc_path,
                                       parser: parser)
    test_doc.add_row ['a'], output: 1
    test_doc.add_row ['b'], output: 0
    test_doc.results.must_equal [[['b']], [['a']]]
  end
end
