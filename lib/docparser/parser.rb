$LOAD_PATH.unshift __dir__
require 'rubygems'
require 'bundler/setup'
require 'version'
require 'output'
require 'document'
require 'nokogiri'
require 'open-uri'
require 'parallel'
require 'set'
require 'log4r'
require 'log4r/formatter/patternformatter'
require 'output/screen_output.rb'
require 'output/csv_output.rb'
require 'output/html_output.rb'
require 'output/xlsx_output.rb'
require 'output/yaml_output.rb'
require 'output/json_output.rb'
require 'output/multi_output.rb'

Log4r.define_levels(*Log4r::Log4rConfig::LogLevels)
logger = Log4r::Logger.new('docparser')
output = Log4r::Outputter.stderr
output.formatter = Log4r::PatternFormatter.new(pattern: '[%l %C] %d :: %m')
logger.outputters = output
logger.level = Log4r::INFO
logger = nil
output = nil

# The DocParser namespace
# See README.md for information on using DocParser
module DocParser
  # The main parser class. This is the class you'll use to create your parser
  # The real work happens in the Document class
  # @see Document
  class Parser
    # @!visibility private
    attr_reader :outputs, :files

    # Creates a new parser instance
    # @param files [Array] An array containing URLs or paths to files
    # @param quiet [Boolean] Be quiet
    # @param encoding [String] The encoding to use for opening the files
    # @param parallel [Boolean] Use parallel processing
    # @param output [Output, Array] The output(s), defaults to a Screenoutput
    # @param range [Range] Range of files to process (nil means process all)
    # @param num_processes [Fixnum] Number of parallel processes
    def initialize(files: [], quiet: false, encoding: 'utf-8', parallel: true,
                   output: ScreenOutput.new, range: nil,
                   num_processes: Parallel.processor_count + 1)
      @num_processes = parallel ? num_processes : 1
      @files = range ? files[range] : files
      @encoding = encoding

      Log4r::Logger['docparser'].level = quiet ? Log4r::ERROR : Log4r::INFO

      if output.is_a? Output
        @outputs = []
        @outputs << output
      elsif output.is_a?(Array) && output.all? { |o| o.is_a? Output }
        @outputs = output
      else
        raise ArgumentError, 'No outputs specified'
      end

      @resultsets = Array.new(@outputs.length) { Set.new }

      @logger =  Log4r::Logger.new('docparser::parser')
      @logger.info "DocParser v#{VERSION}"
      @logger.info "#{@files.length} files loaded (encoding: #{@encoding})"
    end

    #
    # Parses the `files`
    #
    def parse!(&block)
      @logger.info "Parsing #{@files.length} files."
      start_time = Time.now

      if @num_processes > 1
        @logger.info "Starting #{@num_processes} processes"
        Parallel.map(@files, in_processes: @num_processes) do |file|
          parse_doc(file, &block)
        end.each do |result|
          result.each_with_index { |set, index| @resultsets[index].merge(set) }
        end
      else
        @files.each do |file|
          parse_doc(file, &block).each_with_index do |set, index|
            @resultsets[index].merge(set)
          end
        end
      end

      @logger.info 'Processing finished'

      write_to_outputs

      @logger.info sprintf('Done processing in %.2fs.', Time.now - start_time)
    end
  end

  private

  def parse_doc(file, &block)
    doc = Document.new(file, encoding: @encoding, parser: self)
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