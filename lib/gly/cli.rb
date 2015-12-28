require 'thor'

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
    def preview(*files)
      files.each do |f|
        gen = PreviewGenerator.new options: options
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

    private

    def parser
      Parser.new options[:separator]
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
