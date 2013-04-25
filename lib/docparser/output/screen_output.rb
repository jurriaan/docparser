require 'terminal-table'
require 'pageme'
module DocParser
  # This Output can be used for debugging purposes.

  # It pipes all rows through a pager
  # @see Output
  class ScreenOutput < Output
    # @!visibility private

    include PageMe

    def initialize
      @tables = []
      @rowcount = 0
    end

    def close
      page do |p|
        p.puts "Showing all #{@tables.length} rows:\n\n"
        @tables.each do |table|
          p.puts table
        end
      end
    end

    def write_row(row)
      raise MissingHeaderException if @header.nil? || @header.length == 0
      out = []
      0.upto(@header.length - 1) do |counter|
        out << [@header[counter], row[counter]]
      end
      @tables << Terminal::Table.new(rows: out)
    end
  end
end