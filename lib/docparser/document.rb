require 'nokogiri'
module DocParser
  # The Document class loads and parses the files.
  # @see Parser
  # @see Output
  class Document
    # @return [String] the filename of the current document
    attr_reader :filename

    # @return [Nokogiri::HTML::Document] a reference to the Nokogiri document
    attr_reader :doc

    # @return [String] the encoding of the document
    attr_reader :encoding

    # @return [Array] the results from this document
    attr_reader :results

    # @return [String] the source of the document
    attr_reader :html

    def initialize(filename: nil, encoding: 'utf-8', parser: nil)
      @logger = Log4r::Logger.new('docparser::document')
      @logger.debug { "Parsing #{filename}" }
      @encoding = encoding
      @parser = parser
      @filename = filename
      @results = Array.new(@parser.outputs ? @parser.outputs.length : 0) { [] }
      read_file
    end

    # Adds a row to an output
    def add_row(*row, output: 0)
      output = @parser.outputs.index(output) if output.is_a? Output
      @logger.debug { "#{filename}: Adding row #{row.flatten.to_s}" }
      results[output] << row.flatten
    end

    # Extracts the document title
    # @return [String] the title of the document
    def title
      @title ||= xpath_content('//head/title')
    end

    # Executes a xpath query
    def xpath(query)
      res = @doc.search(query)
      if block_given?
        res.each { |el| yield el }
      else
        res
      end
    end

    # Executes a xpath query and returns the content
    # @return [String] the content of the HTML node
    def xpath_content(query)
      first = @doc.search(query).first
      if first.nil?
        nil
      else
        first.content
      end
    end

    # Matches the HTML source using a regular expression
    def regexp(regexp)
      html.match(regexp)
    end

    # Parses the document
    # @return [Array] containing the parse results
    def parse!(&block)
      instance_exec(&block)
      results
    end

    # @!visibility private
    def inspect
      "<Document file:'#{@filename}', encoding:'#{@encoding}'>"
    end

    private

    def read_file
      encodingstring = @encoding == 'utf-8' ? 'r:utf-8' : "r:#{encoding}:utf-8"
      open(@filename, encodingstring) do |f|
        @html = f.read
        @logger.warn "#{filename} is empty" if @html.empty?
        @doc = Nokogiri(@html)
      end
    end

    alias_method :css, :xpath
    alias_method :css_content, :xpath_content
  end
end
