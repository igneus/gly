module Gly
  # converts parsed gly to gabc
  class GabcConvertor
    def convert(score, out=StringIO.new)
      score.headers.each_pair do |key,value|
        out.print '% ' unless Headers.gregorio_supported?(key)
        out.puts "#{key}: #{value};"
      end

      out.puts '%%'

      lyric_enum = score.lyrics.each_syllable.to_enum
      score.music.each_with_index do |mus_chunk,i|
        unless clef?(mus_chunk) ||
               (nonlyrical_chunk?(mus_chunk) && ! nonlyrical_lyrics?(lyric_enum.peek))
          begin
            out.print strip_directives lyric_enum.next
          rescue StopIteration
            out.print ' '
          end
        end
        out.print "(#{mus_chunk})"
      end

      return out
    end

    def clef?(chunk)
      chunk =~ /\A[cf][1-4]\Z/
    end

    # is the given music chunk capable of bearing lyrics?
    def nonlyrical_chunk?(chunk)
      chunk =~ /\A*[,;:]+\Z/ # differentia
    end

    def nonlyrical_lyrics?(syl)
      syl =~ /\A\s*!/ || syl =~ /\A\s*\*\Z/
    end

    def strip_directives(syl)
      syl.sub(/(\s*)!/, '\1') # exclamation mark at the beginning - place even under nonlyrical music chunk
    end
  end
end
