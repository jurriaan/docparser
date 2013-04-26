require 'axlsx'
module DocParser
  # The XLSXOutput class generates Microsoft Excel compatible .xlsx files
  # using the great axslx library
  # @see Output
  class XLSXOutput < Output
    # @!visibility private
    def open_file
      @package = Axlsx::Package.new
      @package.workbook.date1904 = false # Fix for OS X
      @sheet = @package.workbook.add_worksheet
      @file.close
    end

    def header
      write_row @header
    end

    def write_row(row)
      @sheet.add_row row
    end

    def footer
      unless @header.nil?
        @sheet.add_table "A1:#{@sheet.cells.last.r}", name: 'Data'
      end
      @package.serialize @filename
    end

    def rowcount
      if @header.nil?
        @sheet.rows.length
      else
        @sheet.rows.length - 1
      end
    end
  end
end