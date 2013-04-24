module DocParser
  # This Output is used for testing purposes.

  # @see Output
  class NilOutput < Output
    # @!visibility private

    def initialize
    end

    def close
    end

    def write_row(row)
    end
  end
end