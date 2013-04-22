module DocParser
  # The MultiOutput output combines multiple outputs.
  # It creates a CSV, HTML, YAML and XLSX Output file
  # @see CSVOutput
  # @see HTMLOutput
  # @see YAMLOutput
  # @see XLSXOutput
  # @see Output
  class MultiOutput < Output
    # @!visibility private
    def initialize(**options)
      @outputs = []
      csvoptions = options.clone
      csvoptions[:filename] += '.csv'
      htmloptions = options.clone
      htmloptions[:filename] += '.html'
      yamloptions = options.clone
      yamloptions[:filename] += '.yml'
      xlsxoptions = options.clone
      xlsxoptions[:filename] += '.xlsx'
      jsonoptions = options.clone
      jsonoptions[:filename] += '.json'
      @outputs << CSVOutput.new(csvoptions)
      @outputs << HTMLOutput.new(htmloptions)
      @outputs << YAMLOutput.new(yamloptions)
      @outputs << XLSXOutput.new(xlsxoptions)
      @outputs << XLSXOutput.new(jsonoptions)
    end

    def header=(row)
      @outputs.each { |out|  out.header = row.flatten }
    end

    def add_row(row)
      @outputs.each { |out|  out.add_row row.flatten }
    end

    def rowcount
      @outputs.min { |out| out.rowcount }.rowcount
    end

    def close
      @outputs.each { |out|  out.close }
    end
  end
end