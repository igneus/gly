module Gly
  class Lister
    def initialize(files, format=nil)
      @files = files
      @error = false
      @format = find_formatter(format || :grep)
    end

    def list(io, errio)
      @files.each do |f|
        begin
          document = Parser.new.parse(f)
        rescue SystemCallError => err # Errno::WHATEVER
          errio.puts "Cannot read file '#{f}': #{err.message}"
          @error = true
          next
        end

        io.puts @format.file(f)
        document.scores.each do |s|
          io.puts @format.score(s)
        end
      end
    end

    def error?
      @error
    end

    private

    def find_formatter(name)
      formatter_name = name.to_s.capitalize + 'Format'
      begin
        klass = self.class.const_get(formatter_name)
      rescue NameError
        raise Gly::Exception.new("Invalid list format '#{name}'")
      end

      klass.new
    end

    # simple, sort of beautiful, easy to read for a human
    class OverviewFormat
      def file(f)
        "\n== #{f}"
      end

      def score(s)
        l = s.lyrics.readable
        l unless l.empty?
      end
    end

    # less beauty, more repetition, for easier grepping
    class GrepFormat
      def file(f)
        @file = f
        nil
      end

      def score(s)
        "#{@file}##{s.headers['id']} #{s.lyrics.readable}"
      end
    end
  end
end
