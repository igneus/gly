require 'stringio'

module Gly
  # takes Score, translates it to gabc
  class GabcConvertor
    LINE_BREAKING_STRATEGIES = [
      WORD = :word,
      DIVISIO = :divisio,
      LINE = :line,
      NONE = :none
    ].freeze

    def initialize(line_breaking: nil, comment_headers: true)
      @line_breaking = line_breaking || LINE
      unless LINE_BREAKING_STRATEGIES.include? @line_breaking
        raise ArgumentError.new(@line_breaking)
      end

      @comment_headers = comment_headers
    end

    attr_reader :line_breaking

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

        if line_breaking == LINE && signal == Lyrics::END_OF_LINE
          newline_before_next_lyrical = true
        end

        if signal
          if line_breaking == WORD
            next_space = "\n"
          else
            next_space = ' '
          end
        end

        if line_breaking == DIVISIO && divisio?(music_chunk) && signal
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
