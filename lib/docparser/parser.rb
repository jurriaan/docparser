$:.unshift __dir__
require 'rubygems'
require 'bundler/setup'
require 'version'
require 'output'
require 'document'
require 'nokogiri'
require 'open-uri'
require 'parallel'
require 'set'
require 'output/screen_output.rb'
require 'output/csv_output.rb'
require 'output/html_output.rb'
require 'output/xlsx_output.rb'
require 'output/yaml_output.rb'
require 'output/json_output.rb'
require 'output/multi_output.rb'
# {include:file:README.md}
module DocParser
  # The main parser class. This is the class you'll use to create your parser
  # The real work happens in the Document class
  # @see Document
  class Parser
    # @!visibility private
    attr_reader :outputs

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
      @quiet = quiet
      @parallel = parallel
      @num_processes = num_processes
      @encoding = encoding
      if output.is_a? Output
        @outputs = []
        @outputs << output
      elsif output.is_a?(Array) && output.all? { |o| o.is_a? Output }
        @outputs = output
      else
        raise ArgumentError, 'No outputs specified'
      end
      @files = if range
        files[range]
      else
        files
      end
      log 'DocParser loaded..'
      log "#{@files.length} files loaded (encoding: #{@encoding})"
    end

    #
    # Parses the `files`
    #
    def parse!(&block)
      log "Parsing #{@files.length} files."
      start_time = Time.now
      resultsets = Array.new(@outputs.length) { Set.new }

      if @parallel && @num_processes > 1
        log "Starting #{@num_processes} processes"
        Parallel.map(@files, in_processes: @num_processes) do |file|
          Document.new(file, encoding: @encoding, parser: self).parse!(&block)
        end.each do |result|
          result.each_with_index { |set, index| resultsets[index].merge(set) }
        end
        log 'Parallel processing finished, writing results..'
      else
        @files.each do |file|
          doc = Document.new(file, encoding: @encoding, parser: self)
          doc.parse!(&block).each_with_index do |set, index|
            resultsets[index].merge(set)
          end
        end
      end

      log "\nSummary\n======="

      @outputs.each_with_index do |output, index|
        resultsets[index].each do |row|
          output.add_row row
        end
        resultsets[index] = nil
        output.close
        log output.summary
      end

      log ''
      log 'Done processing in %.2fs.' % (Time.now - start_time)
    end

    private

    def log(str)
      puts str unless @quiet
    end
  end
end