module Gly
  # parses gly source
  class Parser
    SYLLABLE_SEP = '--'

    def parse(io)
      @score = ParsedScore.new

      io.each do |line|
        line = strip_comments(line)

        if empty? line
          next
        elsif header_line? line
          parse_header line
        elsif lyrics_line? line
          parse_lyrics line
        else
          parse_music line
        end
      end

      return @score
    end

    def empty?(str)
      str =~ /\A\s*\Z/
    end

    def strip_comments(str)
      str.sub(/%.*\Z/, '')
    end

    def header_line?(str)
      @score.lyrics.empty? && @score.music.empty? && str.include?(':')
    end

    def lyrics_line?(str)
      str.start_with?('\lyrics') || str.include?(SYLLABLE_SEP)
    end

    def parse_header(str)
      hid, hvalue = str.split(':').collect(&:strip)
      @score.headers[hid] = hvalue
    end

    def parse_lyrics(str)
      # words: split by whitespace not being part of syllable
      # separator
      str.split(/(?<!#{SYLLABLE_SEP})\s+(?!#{SYLLABLE_SEP})/).each do |word|
        @score.lyrics << Word.new(word.split(/\s*#{SYLLABLE_SEP}\s*/))
      end
    end

    def parse_music(str)
      # music chunks: split by whitespace out of brackets
      str.split(/\s+/).each do |chunk|
        chunk.sub!(/\A\((.*?)\)\Z/, '\1') # unparenthesize
        @score.music << chunk
      end
    end
  end
end
