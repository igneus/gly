module Gly
  # Result of parsing of a gly file.
  # Usually contains one or more scores
  # and possibly a document header.
  class Document
    def initialize
      @scores = []
      @header = Headers.new
    end

    attr_reader :scores, :header
  end
end
