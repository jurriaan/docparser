require 'multi_json'
module DocParser
  # The JSONOutput class generates a JSON file containing all rows as seperate
  # Array elements
  # @see Output
  class JSONOutput < Output
    # @!visibility private
    def open_file
      @file << '['
      @first = true
      @doc = {}
    end

    def write_row(row)
      raise MissingHeaderException if @header.nil? || @header.length == 0
      if @first
        @first = false
      else
        @file << ','
      end
      0.upto(@header.length - 1) do |counter|
        if row.length > counter
          @doc[@header[counter]] = row[counter]
        else
          @doc[@header[counter]] = ''
        end
      end
      @file << MultiJson.dump(@doc)
    end

    def footer
      @file << ']'
    end
  end
end