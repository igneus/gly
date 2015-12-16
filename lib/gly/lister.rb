module Gly
  class Lister
    def initialize(files)
      @files = files
      @error = false
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

        io.puts
        io.puts "== #{f}"

        document.scores.each do |s|
          l = s.lyrics.readable
          io.puts l unless l.empty?
        end
      end
    end

    def error?
      @error
    end
  end
end
