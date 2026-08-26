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

      in_a_word = false
      @music.each_with_index do |mus_chunk,i|
        begin
          next_syl, _ = lyric_enum.peek
        rescue StopIteration
        end

        if next_syl.nil? || no_lyrics?(mus_chunk, next_syl)
          yield mus_chunk, nil, (in_a_word ? nil : Lyrics::END_OF_WORD)
          next
        end

        begin
          syl, signal = lyric_enum.next
        rescue StopIteration
        end

        in_a_word = signal ? false : (in_a_word || syl)

        yield mus_chunk,
              (syl && strip_directives(syl)),
              (signal.nil? && no_lyrics?(mus_chunk, syl)) ? Lyrics::END_OF_WORD : signal
      end
    end

    private

    def no_lyrics?(music_chunk, syllable)
      clef?(music_chunk) ||
        (unsingable_music_chunk?(music_chunk) &&
         ! nonlyrical_lyrics?(syllable))
    end

    def clef?(chunk)
      chunk =~ /\A[cf]b?[1-4]\Z/
    end

    UNSINGABLE_CHUNK_RE = /
      \A(
      [cf]b?[1-4]          # clef
      |[,`]|:[:']?|;[1-6]? # divisio
      |z0|[a-mnp]\+        # custos
      |[zZ]                # line break
      )+\Z
    /x.freeze

    # is the given music chunk capable of bearing lyrics?
    def unsingable_music_chunk?(chunk)
      chunk.size > 0 &&
        chunk =~ UNSINGABLE_CHUNK_RE
    end

    def nonlyrical_lyrics?(syl)
      syl =~ /\A\s*!/ || syl =~ /\A\s*\*\Z/
    end

    def strip_directives(syl)
      syl.sub(/^!/, '') # exclamation mark at the beginning - place even under nonlyrical music chunk
    end
  end
end
