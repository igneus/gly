module Gly
  # Result of parsing of a gly file.
  # Usually contains one or more scores
  # and possibly a document header.
  class Document
    def initialize
      @scores = []
      @content = []
      @scores_by_id = {}
      @header = Headers.new
      @path = nil
    end

    # only Scores
    attr_reader :scores

    # Scores and Markups
    attr_reader :content

    attr_reader :header
    attr_accessor :path

    # append a new Score (or Markup)
    def <<(score)
      @content << score

      if score.is_a? Score
        @scores << score

        sid = score.headers['id']
        if sid
          if @scores_by_id.has_key? sid
            raise ArgumentError.new("More than one score with id '#{sid}'.")
          end

          @scores_by_id[sid] = score
        end
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
