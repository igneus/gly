module Gly
  # result of a gly score parsing
  class Score
    def initialize
      @headers = Headers.new
      @lyrics = Lyrics.new
      @music = []
    end

    attr_reader :headers, :lyrics, :music

    def empty?
      @headers.empty? && @lyrics.empty? && @music.empty?
    end

    def music_with_lyrics
      MusicWithLyrics.new(music, lyrics)
    end
  end
end
