require 'stringio'

module Gly
  # takes Score, translates it to gabc
  class GabcConvertor
    def initialize(**options)
      @break_words = options[:break_words]
      @break_divisiones = options[:break_divisiones]
      @break_lines = options[:break_lines]
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

      next_space = false
      newline_before_next_lyrical = false
      score.music_with_lyrics.each_pair do |music_chunk, lyric_chunk, signal|
        if newline_before_next_lyrical && lyric_chunk
          out.puts
          newline_before_next_lyrical = false
          next_space = false
        end

        if next_space
          out.print next_space
          next_space = false
        end

        out.print lyric_chunk if lyric_chunk
        out.print "(#{music_chunk})" if music_chunk

        if @break_lines && signal == Lyrics::END_OF_LINE
          newline_before_next_lyrical = true
        end

        if signal
          if @break_words
            next_space = "\n"
          else
            next_space = ' '
          end
        end

        if @break_divisiones && divisio?(music_chunk) && signal
          next_space = "\n"
        end
      end

      out.puts unless score.music.empty?

      return out
    end

    private

    def divisio?(music_chunk)
      music_chunk =~ /[,;:]/
    end
  end
end
