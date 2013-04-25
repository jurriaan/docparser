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
      @rowcount += 1
      write_row @header
    end

    def write_row(row)
      @sheet.add_row row
    end

    def footer
      @sheet.add_table "A1:#{@sheet.cells.last.r}", name: 'Data'
      @package.serialize @filename
    end

    def rowcount
      @sheet.rows.length
    end
  end
end