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

    def build
      @gabcs.each do |g|
        outfile = g.sub /(\.gabc)?$/i, '.gtex'
        exec('gregorio', '-o', outfile, g)
      end

      exec 'lualatex', @main_tex
    end

    private

    def exec(progname, *args)
      ok = system progname, *args
      unless ok
        case $?.exitstatus
        when 127
          STDERR.puts "'#{progname}' is required for this gly command to work, but it was not found. Please, ensure that '#{progname}' is installed in one of the directories listed in your PATH and try again."
        else
          STDERR.puts "'#{progname}' exited with exit code #{$?.to_i}. Let's continue and see what happens ..."
        end
      end
    end
  end
end
