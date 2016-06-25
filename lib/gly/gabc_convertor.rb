require 'stringio'

module Gly
  # takes Score, translates it to gabc
  class GabcConvertor
    def convert(score, out=StringIO.new)
      score.headers.each_pair do |key,value|
        out.print '% ' unless Headers.gregorio_supported?(key)
        out.puts "#{key}: #{value};"
      end

      out.puts '%%'

      score.music_with_lyrics.each_pair do |music_chunk, lyric_chunk|
        out.print lyric_chunk if lyric_chunk
        out.print "(#{music_chunk})" if music_chunk
      end

      out.puts unless score.music.empty?

      return out
    end
  end
end
