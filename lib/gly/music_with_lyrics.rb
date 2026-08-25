module Gly
  # knows how to "zip" music and lyric chunks together
  class MusicWithLyrics
    def initialize(music, lyrics)
      @music = music
      @lyrics = lyrics
    end

    def each_pair
      return enum_for(:each_pair) unless block_given?

      lyric_enum = @lyrics.each_syllable.to_enum

      @music.each_with_index do |mus_chunk,i|
        begin
          next_syl, _ = lyric_enum.peek
        rescue StopIteration
        end

        if next_syl.nil? || no_lyrics?(mus_chunk, next_syl)
          yield mus_chunk, nil, Lyrics::END_OF_WORD
          next
        end

        begin
          lyr, signal = lyric_enum.next
        rescue StopIteration
        end

        yield mus_chunk,
              (lyr && strip_directives(lyr)),
              (signal.nil? && no_lyrics?(mus_chunk, lyr)) ? Lyrics::END_OF_WORD : signal
      end
    end

    private

    def no_lyrics?(music_chunk, syllable)
      clef?(music_chunk) ||
        (nonlyrical_chunk?(music_chunk) &&
         ! nonlyrical_lyrics?(syllable))
    end

    def clef?(chunk)
      chunk =~ /\A[cf]b?[1-4]\Z/
    end

    def without_differentiae(chunk)
      chunk.gsub /(([,`])|(:[:']?)|(;[1-6]?))/, ''
    end

    def without_breaks(chunk)
      chunk.gsub /[zZ]/, ''
    end

    # is the given music chunk capable of bearing lyrics?
    def nonlyrical_chunk?(chunk)
      chunk.size > 0 &&
        without_breaks(without_differentiae(chunk)).empty?
    end

    def nonlyrical_lyrics?(syl)
      syl =~ /\A\s*!/ || syl =~ /\A\s*\*\Z/
    end

    def strip_directives(syl)
      syl.sub(/^!/, '') # exclamation mark at the beginning - place even under nonlyrical music chunk
    end
  end
end
