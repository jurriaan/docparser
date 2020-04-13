# frozen_string_literal: true

require 'cgi'
module DocParser
  # The XLSXOutput class generates an HTML file containing a table
  # @see Output
  class HTMLOutput < Output
    # @!visibility private
    HTMLHEADER = <<~EOS
      <!DOCTYPE html>
      <html>
      <head>
      <title>HTML output "#FILENAME#"</title>
      <meta charset="utf-8">
      <style type="text/css">
      body {
        font-family:"Helvetica Neue", Helvetica, Arial, sans-serif;
        font-size:12px;
      }
      table {
        border:1px solid #69c;
        border-collapse:collapse;
        font-size:12px;
        text-align:left;
        width:480px;
      }
      th {
        border-bottom:1px dashed #69c;
        color:#039;
        font-size:14px;
        font-weight:normal;
        padding:12px 17px;
      }
      td {
        color:#669;
        padding:7px 17px;
        white-space: pre;
      }
      tbody tr:hover td {
        background:#d0dafd;
        color:#339;
      }
      tbody tr:nth-child(even) {
        background:#e0eaff;
      }
      </style>
      </head>
      <body>
      <table>
    EOS
    # @!visibility private
    HTMLFOOTER = <<~EOS
      </tbody>
      </table>
      <p>#COUNT# rows</p>
      </body>
      </html>
    EOS
    def open_file
      @file << HTMLHEADER.gsub('#FILENAME#', @filename)
    end

    def header
      return if @header.nil? || @header.empty?

      @file << '<thead><tr>'
      @file << @header.map { |f| '<th>' + f + '</th>' }.join
      @file << "</tr></thead>\n<tbody>\n"
      @tbody = true
    end

    def write_row(row)
      unless @tbody
        @file << "<tbody>\n"
        @tbody = true
      end
      @file << '<tr>'
      @file << row.map { |f| '<td>' + CGI.escapeHTML(f.to_s) + '</td>' }.join
      @file << "</tr>\n"
    end

    def footer
      @file << HTMLFOOTER.gsub('#COUNT#', @rowcount.to_s)
    end
  end
end
