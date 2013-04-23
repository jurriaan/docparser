require 'json'
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
      if @first
        @first = false
      else
        @file << ','
      end
      0.upto(@header.length - 1) do |counter|
        if row.has_key? counter
          @doc[@header[counter]] = row[counter]
        else
          @doc[@header[counter]] = ''
        end
      end
      @file << JSON.dump(@doc)
    end

    def close
      @file << ']'
    end
  end
end