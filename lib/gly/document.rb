module Gly
  # Result of parsing of a gly file.
  # Usually contains one or more scores
  # and possibly a document header.
  class Document
    def initialize
      @scores = []
      @header = Headers.new
      @path = nil
    end

    attr_reader :scores, :header
    attr_accessor :path
  end
end
