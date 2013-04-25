require 'csv'
module DocParser
  # The CSVOutput class generates a CSV file containing all rows
  # @see Output

  class CSVOutput < Output
    # @!visibility private
    def open_file
      @csv = CSV.new(@file, col_sep: ';')
    end

    def header
      write_row @header
      @rowcount += 1
    end

    def write_row(row)
      @csv << row
    end
  end
end