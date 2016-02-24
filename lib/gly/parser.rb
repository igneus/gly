require 'stringio'

module Gly
  # parses gly source
  class Parser
    def initialize(syllable_separator=nil)
      @syllable_separator = syllable_separator || '--'
      @current_block = :score
    end

    def parse(source)
      if source.is_a? String
        if File.file? source
          parse_fname source
        elsif source == '-'
          parse_io STDIN
        else
          parse_str source
        end
      else
        parse_io source
      end
    end

    def parse_fname(str)
      File.open(str) do |fr|
        parse_io fr
      end
    end

    def parse_str(str)
      parse_io(StringIO.new(str))
    end

    def parse_io(io)
      @doc = Document.new
      @score = ParsedScore.new

      if io.respond_to? :path
        @doc.path = io.path
      end

      io.each do |line|
        line = strip_comments(line)

        if empty? line
          next
        # keywords specifying line or block type
        elsif new_score? line
          push_score
          @score = ParsedScore.new
          @current_block = :score
        elsif header_start? line
          push_score
          @score = @doc.header
          @current_block = :header
        elsif block_start? line
          @current_block = line.match(/\w+/)[0].to_sym
        elsif explicit_lyrics? line
          parse_lyrics line
        elsif explicit_music? line
          parse_music line
        # line in a typed block
        elsif @current_block != :score
          parse_default line
        # content type autodetection
        elsif markup_line? line
          push_score
          parse_markup line
        elsif header_line? line
          parse_header line
        elsif lyrics_line? line
          parse_lyrics line
        else
          parse_default line
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

    def block_start?(str)
      str =~ /\A\s*\\(lyrics|markup|music)\s*\Z/
    end

    def strip_comments(str)
      str.sub(/%.*\Z/, '')
    end

    def header_line?(str)
      @current_block == :header || @current_block == :score && @score.lyrics.empty? && @score.music.empty? && str =~ /\A[\w_-]+:/
    end

    EXPLICIT_LYRICS_RE = /\A\\l(yrics)?\s+/

    def explicit_lyrics?(str)
      str =~ EXPLICIT_LYRICS_RE
    end

    EXPLICIT_MUSIC_RE = /\A\\m(usic)?\s+/

    def explicit_music?(str)
      str =~ EXPLICIT_MUSIC_RE
    end

    def lyrics_line?(str)
      !contains_square_brackets?(str) && (str.include?(@syllable_separator) || contains_unmusical_letters?(str))
    end

    def markup_line?(str)
      str.start_with? '\markup'
    end

    def contains_unmusical_letters?(str)
      letters = str.gsub(/[\W\d_]+/, '')
      letters !~ /\A[a-morsvwxz]*\Z/i # incomplete gabc music letters!
    end

    def contains_square_brackets?(str)
      str.include? '['
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
        .split(/(?<!#{@syllable_separator})\s+(?!#{@syllable_separator})/)
        .each do |word|
        @score.lyrics << Word.new(word.split(/\s*#{@syllable_separator}\s*/))
      end
    end

    def parse_music(str)
      str = str.sub(EXPLICIT_MUSIC_RE, '')

      # music chunks: split by whitespace out of brackets
      StringHelpers.music_split(str).each do |chunk|
        @score.music << chunk
      end
    end

    def parse_markup(line)
    end

    def parse_default(line)
      if @current_block == :score
        return parse_music line
      end

      send "parse_#{@current_block}", line
    end

    def push_score
      if @score.is_a?(ParsedScore) && !@score.empty?
        begin
          @doc << @score
        rescue ArgumentError => ex
          raise ParseError.wrap ex
        end
      end
      @score = nil
    end
  end
end
