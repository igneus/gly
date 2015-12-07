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
        unless nonlyrical_chunk?(mus_chunk)
          begin
            out.print lyric_enum.next
          rescue StopIteration
            out.print ' '
          end
        end
        out.print "(#{mus_chunk})"
      end

      return out
    end

    # is the given music chunk capable of bearing lyrics?
    def nonlyrical_chunk?(chunk)
      chunk =~ /\A([cf][1-4]|[.,;:]+)\Z/ # clef or differentia
    end
  end
end
