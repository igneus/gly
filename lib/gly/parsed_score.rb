module Gly
  # result of a gly score parsing
  class ParsedScore
    def initialize
      @headers = Headers.new
      @lyrics = Lyrics.new
      @music = []
    end

    attr_reader :headers, :lyrics, :music
  end
end
