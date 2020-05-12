require 'stringio'

module Gly
  # takes Score, translates it to gabc
  class GabcConvertor
    def initialize(options={})
      @line_limit = options[:line_limit]
      @break_words = options[:break_words]
      @break_divisiones = options[:break_divisiones]
      @comment_headers = options.fetch :comment_headers, true
    end

    def convert(score, out=StringIO.new)
      score.headers.each_pair do |key,value|
        if @comment_headers && !Headers.gregorio_supported?(key)
          out.print '% '
        end
        out.puts "#{key}: #{value};"
      end

      out.puts '%%'

      score.music_with_lyrics.each_pair do |music_chunk, lyric_chunk|
        if @break_words && word_boundary?(music_chunk, lyric_chunk)
          out.puts
          next
        end

        out.print lyric_chunk if lyric_chunk
        out.print "(#{music_chunk})" if music_chunk

        if @break_divisiones && divisio?(music_chunk)
          out.puts
        end
      end

      out.puts unless score.music.empty?

      return out
    end

    private

    def word_boundary?(music_chunk, lyric_chunk)
      music_chunk == nil && lyric_chunk == ' '
    end
  end
end
