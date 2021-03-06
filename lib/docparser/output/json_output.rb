# frozen_string_literal: true

require 'json'
module DocParser
  # The JSONOutput class generates a JSON file containing all rows as seperate
  # Array elements
  # @see Output
  class JSONOutput < Output
    # @!visibility private
    def open_file
      @file << '['
      @doc = {}
    end

    def write_row(row)
      raise MissingHeaderException if @header.nil? || @header.empty?

      @file << ',' unless @file.pos <= 1

      0.upto(@header.length - 1) do |counter|
        @doc[@header[counter]] = row.length > counter ? row[counter] : ''
      end

      @file << JSON.generate(@doc)
    end

    def footer
      @file << ']'
    end
  end
end
