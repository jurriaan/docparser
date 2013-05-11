require 'set'
module DocParser
  # The Document class loads and parses the files.
  # @see Parser
  # @see Output
  class Document
    attr_reader :filename, :doc, :encoding, :results

    # @return [String] the source of the document
    attr_reader :html

    def initialize(filename: nil, encoding: 'utf-8', parser: nil)
      if encoding == 'utf-8'
        encodingstring = 'r:utf-8'
      else
        encodingstring = "r:#{encoding}:utf-8"
      end
      @logger = Log4r::Logger.new('docparser::document')
      @logger.debug { "Parsing #{filename}" }
      open(filename, encodingstring) do |f|
        @html = f.read
        @logger.warn "#{filename} is empty" if @html.empty?
        @doc = Nokogiri(@html)
      end
      @encoding = encoding
      @parser = parser
      @filename = filename
      @results = Array.new(@parser.outputs ? @parser.outputs.length : 0) { [] }
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

    alias_method :css, :xpath
    alias_method :css_content, :xpath_content
  end
end