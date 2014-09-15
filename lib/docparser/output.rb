module DocParser
  # The Output base class.
  # All Output classes inherit from this one.
  class Output
    attr_reader :rowcount, :filename

    # Creates a new output
    #
    # You can assign the output to the Parser so it automatically writes all
    # data to the file you want.
    #
    # Do not use this class as an output, instead use one of the classes that
    # inherit from it
    #
    # @param filename [String] Output filename
    # @see Parser
    # @see CSVOutput
    # @see HTMLOutput
    # @see YAMLOutput
    # @see XLSXOutput
    # @see MultiOutput
    def initialize(filename: nil, uniq: false)
      @rowcount = 0
      @filename = filename
      @uniq = uniq
      @uniqarr = []
      fail ArgumentError, 'Please specify a filename' if filename.empty?
      @file = open filename, 'w'
      classname = self.class.name.split('::').last
      @logger = Log4r::Logger.new("docparser::output::#{classname}")
      open_file
    end

    # Stores the header
    def header=(row)
      @header = row
      header
    end

    # Adds a row
    def add_row(row)
      return if @uniq && @uniqarr.include?(row.hash)
      @rowcount += 1
      write_row row
      @uniqarr << row.hash
    end

    # Closes output and IO
    def close
      footer
      @file.close unless @file.closed?
      @logger.info 'Finished writing'
      size = File.size(@filename) / 1024.0
      @logger.info format('%s: %d rows, %.2f KiB', @filename, rowcount, size)
    end

    # Called after the file is opened
    def open_file
      # do nothing
    end

    # Called after header is set
    def header
      # do nothing
    end

    # Called when a row is added
    def write_row(_row)
      fail NotImplementedError, 'No row writer defined'
    end

    # Called before closing the file
    def footer
    end
  end

  # MissingHeaderException gets thrown if a required header is missing.
  class MissingHeaderException < StandardError; end
end
