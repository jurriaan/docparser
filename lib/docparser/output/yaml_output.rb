require 'yaml'
module DocParser
  # The YAMLOutput class generates a YAML file containing all rows as seperate
  # YAML documents
  # @see Output
  class YAMLOutput < Output
    # @!visibility private
    def write_row(row)
      fail MissingHeaderException if @header.nil? || @header.length == 0
      @doc ||= {}

      0.upto(@header.length - 1) do |counter|
        @doc[@header[counter]] = row.length > counter ? row[counter] : ''
      end

      YAML.dump @doc, @file
    end
  end
end
