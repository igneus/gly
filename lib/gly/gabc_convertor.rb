require 'stringio'

module Gly
  # takes ParsedScore, translates it to gabc
  class GabcConvertor
    def convert(score, out=StringIO.new)
      score.headers.each_pair do |key,value|
        out.print '% ' unless Headers.gregorio_supported?(key)
        out.puts "#{key}: #{value};"
      end

      out.puts '%%'

      lyric_enum = score.lyrics.each_syllable.to_enum

      score.music.each_with_index do |mus_chunk,i|
        begin
          next_syl = lyric_enum.peek
          out.print lyric_enum.next if next_syl == ' '
        rescue StopIteration
          next_syl = ''
        end until next_syl != ' '

        if no_lyrics? mus_chunk, next_syl
          if i == score.music.size - 1
            out.print ' '
          end
        else
          # regular music chunk
          begin
            out.print strip_directives lyric_enum.next
          rescue StopIteration
            out.print ' ' if i > 0 # don't add space at the very beginning
          end
        end

        out.print "(#{mus_chunk})"
        if no_lyrics?(mus_chunk, next_syl) &&
           i != (score.music.size - 1) &&
           ! score.lyrics.empty?
          out.print ' '
        end
      end

      return out
    end

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
