require 'thor'

begin
  require 'lygre'
rescue LoadError
end

module Gly
  # implements the 'gly' executable
  class CLI < Thor
    class_option :separator, aliases: :s, banner: 'syllable separator (default is double dash "--")'

    desc 'gabc FILE ...', 'convert gly to gabc'
    option :output, type: :string, aliases: :o, banner: 'specify output file name (or template of file names)'
    option :output_directory, aliases: :d, type: :string, banner: 'specify output directory'
    option :break_lines, type: :boolean, aliases: :L, banner: 'line-breaks as in source lyrics (default)'
    option :break_words, type: :boolean, aliases: :W, banner: 'line-break after each word'
    option :break_divisiones, type: :boolean, aliases: :D, banner: 'line-break after each division ("bar line")'
    option :no_break, type: :boolean, aliases: :N, banner: 'no line-breaking, produce gabc music as one long line'
    def gabc(*files)
      gc = GabcConvertor
      gabc_options = {
        line_breaking: {
          break_words: gc::WORD,
          break_divisiones: gc::DIVISIO,
          break_lines: gc::LINE,
          no_break: gc::NONE,
        }.each_pair
          .find {|(opt, _)| options[opt] }
          &.last
      }

      files.each do |f|
        DocumentGabcConvertor.new(
          parser.parse(input_file(f)),
          output_file: options[:output],
          output_directory: options[:output_directory],
          gabc_options: gabc_options
        ).convert
      rescue Errno::ENOENT
        raise Gly::Exception.new("File not found: '#{f}'")
      end
    rescue Gly::Exception => ex
      error_exit! ex
    end

    desc 'preview FILE ...', 'convert to gabc AND generate pdf preview'
    option :no_build, type: :boolean, aliases: :B, banner: 'only generate preview assets, don\'t compile them'
    option :no_document, type: :boolean, aliases: :D, banner: 'produce main LaTeX file without document definition; in this case --no-build is applied automatically'
    option :output_directory, aliases: :d, type: :string, banner: 'specify output directory'
    option :full_headers, type: :boolean, aliases: :H, banner: 'include full document and score headers'
    option :template, aliases: :t, banner: 'use custom document template'
    def preview(*files)
      tpl = nil
      if options[:template]
        begin
          tpl = File.read(options[:template])
        rescue Errno::ENOENT
          raise Gly::Exception.new("File not found: '#{options[:template]}'")
        end
      end

      # convert HashWithIndifferentAccess to Hash
      # with Symbol keys - options.to_h would make Hash
      # with String keys
      opts = options.each_pair.collect {|k,v| [k.to_sym,v]}.to_h

      opts[:suffix_always] = true

      files.each do |f|
        gen = PreviewGenerator.new template: tpl, options: opts
        document =
          begin
            parser.parse input_file f
          rescue Errno::ENOENT => e
            raise Gly::Exception.new("File not found: '#{f}'")
          end
        gen.process(document)
      end

    rescue Gly::Exception => ex
      error_exit! ex
    end

    desc 'list FILE ...', 'list scores contained in files'
    option :recursive, type: :boolean, aliases: :r, banner: 'recursively traverse directories', default: false
    option :format, type: :string, aliases: :f, banner: 'grep|overview'
    def list(*files)
      if files.empty?
        STDERR.puts 'No file specified.'
        exit 1
      end

      files =
        if options[:recursive]
          files.flat_map do |f|
            if File.directory?(f)
              Dir[File.join(f, '**/*.gly')]
            else
              input_file f
            end
          end
        else
          files.collect {|f| input_file f }
        end

      lister = Lister.new(files, options[:format])
      lister.list(STDOUT, STDERR)

      exit(lister.error? ? 1 : 0)
    rescue Gly::Exception => ex
      error_exit! ex
    end

    desc 'ly FILE ...', 'transform gly document to lilypond document (requires lygre)'
    option :output_directory, aliases: :d, type: :string, banner: 'specify output directory'
    def ly(*files)
      check_lygre_available!

      files.each do |f|
        document =
          begin
            parser.parse input_file f
          rescue Errno::ENOENT => e
            raise Gly::Exception.new("File not found: '#{f}'")
          end

        DocumentLyConvertor.new(document, output_directory: options[:output_directory]).convert
      end

    rescue Gly::Exception => ex
      error_exit! ex
    end

    desc 'fy FILE ...', 'transform gabc to gly (requires lygre)'
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

    desc 'version', 'print gly version'
    def version
      puts "gly #{VERSION}, released #{RELEASE_DATE}"

      # TODO currently lygre doesn't expose version information
      puts 'lygre' + (lygre_available? ? '' : ' not') + ' available'

      GregorioVersionDetector.version&.yield_self do |v|
        puts "gregorio #{v}"
        if v.segments[0] != 6
          puts '!!! watch out for problems, this gly version expects gregorio v6'
        end
      end
    end

    private

    def parser
      Parser.new options[:separator]
    end

    # normalize input file name (support extension-less input
    # file names like programs from the TeX family generally do)
    def input_file(f)
      if File.exist?(f)
        f
      else
        f + '.gly'
      end
    end

    def lygre_available?
      defined? LilypondConvertor
    end

    def check_lygre_available!
      unless lygre_available?
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

    def error_exit!(exception)
      STDERR.puts 'ERROR: ' + exception.message
      exit 1
    end
  end
end
