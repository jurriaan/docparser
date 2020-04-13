# frozen_string_literal: true

module DocParser
  # This Output is used for testing purposes.

  # @see Output
  # @!visibility private
  class NilOutput < Output
    def initialize
      @rowcount = 0
    end

    def close; end

    def write_row(*); end

    def add_row(*); end
  end
end
