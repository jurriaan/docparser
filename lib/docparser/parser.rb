require 'rubygems'
require 'bundler/setup'
require 'open-uri'
require 'parallel'
require 'set'
require 'log4r'
require 'log4r/formatter/patternformatter'
require 'docparser/version'
require 'docparser/output'
require 'docparser/document'
require 'docparser/output/screen_output.rb'
require 'docparser/output/csv_output.rb'
require 'docparser/output/html_output.rb'
require 'docparser/output/xlsx_output.rb'
require 'docparser/output/yaml_output.rb'
require 'docparser/output/json_output.rb'
require 'docparser/output/multi_output.rb'
require 'docparser/output/nil_output.rb'

Log4r.define_levels(*Log4r::Log4rConfig::LogLevels)
logger = Log4r::Logger.new('docparser')
output = Log4r::StdoutOutputter.new('docparser')
output.formatter = Log4r::PatternFormatter.new(pattern: '[%l %C] %d :: %m')
logger.outputters = output
logger.level = Log4r::INFO

# The DocParser namespace
# See README.md for information on using DocParser
module DocParser
  # The main parser class. This is the class you'll use to create your parser
  # The real work happens in the Document class
  # @see Document
  class Parser
    # @!visibility private
    attr_reader :outputs, :files, :num_processes, :encoding

    # Creates a new parser instance
    # @param files [Array] An array containing URLs or paths to files
    # @param quiet [Boolean] Be quiet
    # @param encoding [String] The encoding to use for opening the files
    # @param parallel [Boolean] Use parallel processing
    # @param output [Output, Array] The output(s), defaults to a Screenoutput
    # @param range [Range] Range of files to process (nil means process all)
    # @param num_processes [Fixnum] Number of parallel processes
    def initialize(files: [], quiet: false, encoding: 'utf-8', parallel: true,
                   output: nil, range: nil,
                   num_processes: Parallel.processor_count + 1)
      @num_processes = parallel ? num_processes : 1
      @files = range ? files[range] : files
      @encoding = encoding

      Log4r::Logger['docparser'].level = quiet ? Log4r::ERROR : Log4r::INFO

      initialize_outputs output

      @logger =  Log4r::Logger.new('docparser::parser')
      @logger.info "DocParser v#{VERSION} loaded"
    end

    #
    # Parses the `files`
    #
    def parse!(&block)
      @logger.info "Parsing #{@files.length} files (encoding: #{@encoding})."
      start_time = Time.now

      if @num_processes > 1
        parallel_process(&block)
      else
        serial_process(&block)
      end

      @logger.info 'Processing finished'

      write_to_outputs

      @logger.info sprintf('Done processing in %.2fs.', Time.now - start_time)
    end

    private

    def initialize_outputs(output)
      @outputs = []
      if output.is_a? Output
        @outputs << output
      elsif output.is_a?(Array) && output.all? { |o| o.is_a? Output }
        @outputs = output
      elsif !output.nil?
        raise ArgumentError, 'Invalid outputs specified'
      end

      @resultsets = Array.new(@outputs.length) { Set.new }
    end

    def parallel_process(&block)
      @logger.info "Starting #{@num_processes} processes"
      option = RUBY_ENGINE == 'ruby' ? :in_processes : :in_threads
      Parallel.map(@files, { option => @num_processes }) do |file|
        # :nocov: #
        parse_doc(file, &block)
        # :nocov: #
      end.each do |result|
        result.each_with_index do |set, index|
          @resultsets[index].merge(set)
        end if @outputs
      end
    end

    def serial_process(&block)
      @files.each do |file|
        parse_doc(file, &block).each_with_index do |set, index|
          @resultsets[index].merge(set) if @outputs
        end
      end
    end

    def parse_doc(file, &block)
      doc = Document.new(filename: file, encoding: @encoding, parser: self)
      doc.parse!(&block)
    end

    def write_to_outputs
      @logger.info 'Writing data..'
      @outputs.each_with_index do |output, index|
        @resultsets[index].each do |row|
          output.add_row row
        end
        @resultsets[index] = nil
        output.close
      end
    end

  end
end
