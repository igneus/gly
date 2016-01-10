module Gly
  # Result of parsing of a gly file.
  # Usually contains one or more scores
  # and possibly a document header.
  class Document
    def initialize
      @scores = []
      @scores_by_id = {}
      @header = Headers.new
      @path = nil
    end

    attr_reader :scores, :header
    attr_accessor :path

    def <<(score)
      @scores << score

      sid = score.headers['id']
      if sid
        if @scores_by_id.has_key? sid
          raise ArgumentError.new("More than one score with id '#{sid}'.")
        end

        @scores_by_id[sid] = score
      end

      self
    end

    def [](key)
      if key.is_a? Integer
        @scores[key]
      else
        @scores_by_id[key]
      end
    end
  end
end
