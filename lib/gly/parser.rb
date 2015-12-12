module Gly
  # parses gly source
  class Parser
    SYLLABLE_SEP = '--'

    def parse(io)
      @doc = Document.new
      @score = ParsedScore.new

      io.each do |line|
        line = strip_comments(line)

        if empty? line
          next
        elsif new_score? line
          push_score
          @score = ParsedScore.new
        elsif header_start? line
          push_score
          @score = @doc.header
        elsif header_line? line
          parse_header line
        elsif lyrics_line? line
          parse_lyrics line
        else
          parse_music line
        end
      end

      push_score

      return @doc
    end

    private

    def empty?(str)
      str =~ /\A\s*\Z/
    end

    def new_score?(str)
      str =~ /\A\s*\\score/
    end

    def header_start?(str)
      str =~ /\A\s*\\header/
    end

    def strip_comments(str)
      str.sub(/%.*\Z/, '')
    end

    def header_line?(str)
      in_header_block? || @score.lyrics.empty? && @score.music.empty? && str =~ /\w+:\s*./
    end

    EXPLICIT_LYRICS_RE = /\A\\l(yrics)?\s+/

    def lyrics_line?(str)
      str =~ EXPLICIT_LYRICS_RE || str.include?(SYLLABLE_SEP) || contains_unmusical_letters?(str)
    end

    def in_header_block?
      @score.is_a? Headers
    end

    def contains_unmusical_letters?(str)
      letters = str.gsub(/[\W\d_]+/, '')
      letters !~ /\A[a-mvwoxz]*\Z/i # incomplete gabc music letters!
    end

    def parse_header(str)
      hid, hvalue = str.split(':').collect(&:strip)
      @score.headers[hid] = hvalue
    end

    def parse_lyrics(str)
      # words: split by whitespace not being part of syllable
      # separator
      str
        .sub(EXPLICIT_LYRICS_RE, '')
        .split(/(?<!#{SYLLABLE_SEP})\s+(?!#{SYLLABLE_SEP})/)
        .each do |word|
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

    def push_score
      if @score.is_a?(ParsedScore) && !@score.empty?
        @doc.scores << @score
      end
    end
  end
end
