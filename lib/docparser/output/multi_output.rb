module DocParser
  # The MultiOutput output combines multiple outputs.
  # It creates a CSV, HTML, YAML and XLSX Output file
  # @see CSVOutput
  # @see HTMLOutput
  # @see YAMLOutput
  # @see XLSXOutput
  # @see Output
  class MultiOutput < Output
    # All the possible outputs
    OUTPUT_TYPES = { csv: CSVOutput, html: HTMLOutput, yml: YAMLOutput,
                     xlsx: XLSXOutput, json: JSONOutput }

    # @!visibility private
    def initialize(**options)
      @outputs = []
      OUTPUT_TYPES.each do |type, output|
        output_options = options.clone
        output_options[:filename] += '.' + type.to_s
        @outputs << output.new(output_options)
      end
    end

    def header=(row)
      @outputs.each { |out|  out.header = row }
    end

    def add_row(row)
      @outputs.each { |out|  out.add_row row }
    end

    def rowcount
      @outputs.map(&:rowcount).min
    end

    def close
      @outputs.each(&:close)
    end
  end
end
