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
          next_syl = lyric_enum.peek
          yield nil, lyric_enum.next if next_syl == ' '
        rescue StopIteration
          next_syl = ''
        end until next_syl != ' '

        if no_lyrics? mus_chunk, next_syl
          if i == @music.size - 1
            yield nil, ' '
          end
        else
          # regular music chunk
          begin
            lyr = strip_directives lyric_enum.next
          rescue StopIteration
            lyr = ' ' if i > 0 # don't add space at the very beginning
          end
        end

        yield mus_chunk, lyr
        if no_lyrics?(mus_chunk, next_syl) &&
           i != (@music.size - 1) &&
           ! @lyrics.empty?
          yield nil, ' '
        end
      end
    end

    private

    def no_lyrics?(music_chunk, syllable)
      clef?(music_chunk) ||
        (nonlyrical_chunk?(music_chunk) &&
         ! nonlyrical_lyrics?(syllable))
    end

    def clef?(chunk)
      chunk =~ /\A[cf][1-4]\Z/
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
      syl.sub(/(\s*)!/, '\1') # exclamation mark at the beginning - place even under nonlyrical music chunk
    end
  end
end
