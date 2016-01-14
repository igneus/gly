require 'thor'

begin
  require 'grely'
rescue LoadError
end

module Gly
  # implements the 'gly' executable
  class CLI < Thor
    class_option :separator, aliases: :s, banner: 'syllable separator (default is double dash "--")'

    desc 'gabc FILE ...', 'convert gly to gabc'
    def gabc(*files)
      files.each do |f|
        DocumentGabcConvertor.new(parser.parse(f)).convert
      end
    end

    desc 'preview FILE ...', 'convert to gabc AND generate pdf preview'
    option :no_build, type: :boolean, aliases: :B, banner: 'only generate preview assets, don\'t compile them'
    option :no_document, type: :boolean, aliases: :D, banner: 'produce main LaTeX file without document definition; in this case --no-build is applied automatically'
    option :full_headers, type: :boolean, aliases: :h, banner: 'include full document and score headers'
    option :template, aliases: :t, banner: 'use custom document template'
    def preview(*files)
      tpl = nil
      tpl = File.read(options[:template]) if options[:template]

      opts = options.to_h
      opts[:suffix_always] = true

      files.each do |f|
        gen = PreviewGenerator.new template: tpl, options: opts
        gen.process(parser.parse(f))
      end
    end

    desc 'list FILE ...', 'list scores contained in files'
    option :recursive, type: :boolean, aliases: :r, banner: 'recursively traverse directories', default: false
    def list(*files)
      if files.empty?
        STDERR.puts 'No file specified.'
        exit 1
      end

      if options[:recursive]
        files = files.collect do |f|
          if File.directory?(f)
            Dir[File.join(f, '**/*.gly')]
          else
            f
          end
        end
        files.flatten!
      end

      lister = Lister.new(files)
      lister.list(STDOUT, STDERR)

      exit(lister.error? ? 1 : 0)
    end

    desc 'ly FILE ...', 'transform gly document to lilypond document'
    def ly(*files)
      check_lygre_available!

      files.each do |f|
        DocumentLyConvertor.new(parser.parse(f)).convert
      end
    end

    desc 'fy FILE ...', 'transform gabc to gly'
    def fy(*files)
      check_lygre_available!

      files.each_with_index do |f,i|
        input = File.read f

        parser = GabcParser.new
        result = parser.parse(input)

        if result then
          puts if i >= 1
          GlyConvertor.new.convert result.create_score, STDOUT
        else
          STDERR.puts 'glyfy considers the input invalid gabc:'
          STDERR.puts
          STDERR.puts "'#{parser.failure_reason}' on line #{parser.failure_line} column #{parser.failure_column}:"
          STDERR.puts input.split("\n")[parser.failure_line-1]
          STDERR.puts (" " * parser.failure_column) + "^"
          return false
        end
      end
    end

    private

    def parser
      Parser.new options[:separator]
    end

    def check_lygre_available!
      unless defined? LilypondConvertor
        STDERR.puts "'lygre' gem not found. Please, install lygre in order to run 'gly ly'."
        exit 1
      end
    end

    class << self
      # override Thor's default handler
      def handle_no_command_error(command, has_namespace=$thor_runner)
        if has_namespace
          fail Thor::UndefinedCommandError, "Could not find command #{command.inspect} in #{namespace.inspect} namespace."
        else
          fail Thor::UndefinedCommandError, "Could not find command #{command.inspect}. Did you mean 'gly preview #{command}' ?"
        end
      end
    end
  end
end
