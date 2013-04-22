module DocParser
  # The Output base class.
  # All Output classes inherit from this one.
  class Output
    attr_reader :rowcount

    # Creates a new output
    # @param filename [String] Output filename
    def initialize(filename: filename)
      @rowcount = 0
      @filename = filename
      raise ArgumentError, 'Please specify a filename' if filename.empty?
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
      @rowcount += 1
      write_row row
    end

    # Closes output and IO
    def close
      footer
      @file.close unless @file.closed?
      @logger.info "Finished writing"
      size = File.size(@filename) / 1024.0
      @logger.info sprintf("%s: %d rows, %.2f KiB", @filename, @rowcount, size)
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
    def write_row(row)
      raise 'No row writer defined'
    end

    # Called before closing the file
    def footer
    end
  end
end