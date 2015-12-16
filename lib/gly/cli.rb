require 'thor'

module Gly
  # implements the 'gly' executable
  class CLI < Thor
    desc 'gabc FILE ...', 'convert gly to gabc'
    def gabc(*files)
      files.each {|f| DocumentGabcConvertor.new(Parser.new.parse(f)).convert }
    end

    desc 'preview FILE ...', 'convert to gabc AND generate pdf preview'
    def preview(*files)
      files.each {|f| PreviewGenerator.new.process(Parser.new.parse(f)) }
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
  end
end
