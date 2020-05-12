module Gly
  # *builds* the pdf preview from assets prepared
  # by PreviewGenerator
  class PreviewBuilder
    def initialize
      @gabcs = []
      @main_tex = nil
    end

    def add_gabc(path)
      @gabcs << path
    end

    attr_accessor :main_tex

    def build_gabcs
      @gabcs.each do |g|
        outfile = g.sub /(\.gabc)?$/i, '.gtex'
        benevolent_exec('gregorio', '-o', outfile, g)
      end
    end

    def build
      build_gabcs

      exec 'lualatex', '--interaction=nonstopmode', @main_tex
    end

    private

    def exec(progname, *args)
      ok = system progname, *args
      unless ok
        case $?.exitstatus
        when 127
          raise Gly::Exception.new "'#{progname}' is required for this gly command to work, but it was not found. Please, ensure that '#{progname}' is installed in one of the directories listed in your PATH and try again."
        else
          raise Gly::Exception.new "'#{progname}' exited with exit code #{$?.to_i}."
        end
      end
    end

    def benevolent_exec(progname, *args)
      begin
        exec progname, *args
      rescue Gly::Exception => err
        STDERR.puts err.message + " Let's continue and see what happens ..."
      end
    end
  end
end
