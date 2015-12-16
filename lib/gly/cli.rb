require 'thor'
require 'stringio'

module Gly
  # implements the 'gly' executable
  class CLI < Thor
    desc 'gabc FILE ...', 'convert gly to gabc'
    def gabc(*files)
      files.each {|f| gabc_convert(parse(f)) }
    end

    desc 'preview FILE ...', 'convert to gabc AND generate pdf preview'
    def preview(*files)
      files.each {|f| make_preview f }
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

      was_error = false

      files.each do |f|
        begin
          document = parse(f)
        rescue SystemCallError => err # Errno::WHATEVER
          STDERR.puts "Cannot read file '#{f}': #{err.message}"
          was_error = true
          next
        end

        puts
        puts "== #{f}"

        document.scores.each do |s|
          l = s.lyrics.readable
          puts l unless l.empty?
        end
      end

      exit(was_error ? 1 : 0)
    end

    private

    def parse(gly_file)
      if gly_file == '-'
        return Parser.new.parse(STDIN)
      end

      document = File.open(gly_file) do |fr|
        Parser.new.parse(fr)
      end
    end

    def gabc_convert(doc)
      doc.scores.each_with_index do |score, si|
        score_id = score.headers['id'] || si.to_s
        out_fname = File.basename(doc.path)
                    .sub(/\.gly\Z/i, "_#{score_id}.gabc")
        File.open(out_fname, 'w') do |fw|
          GabcConvertor.new.convert score, fw
        end
        yield score, out_fname if block_given?
      end
    end

    def make_preview(gly_file)
      doc = parse(gly_file)

      tpl_name = File.join(File.dirname(__FILE__), 'templates/lualatex_document.tex')
      template = File.read(tpl_name)

      doc_body = fw = StringIO.new

      gabc_convert(doc) do |score, gabc_fname|
        system "gregorio #{gabc_fname}"
        gtex_fname = gabc_fname.sub /\.gabc/i, ''
        piece_title = %w(book manuscript arranger author).collect do |m|
          score.headers[m]
        end.delete_if(&:nil?).join ', '
        fw.puts "\\commentary{\\footnotesize{#{piece_title}}}\n" unless piece_title.empty?

        annotations = score.headers.each_value('annotation')
        begin
          fw.puts "\\setfirstannotation{#{annotations.next}}"
          fw.puts "\\setsecondannotation{#{annotations.next}}"
        rescue StopIteration
          # ok, no more annotations
        end

        fw.puts "\\includescore{#{gtex_fname}}\n\\vspace{1cm}"
      end

      replacements = {
        title: doc.header['title'],
        maketitle: (doc.header['title'] && '\maketitle'),
        body: doc_body.string
      }
      tex = template % replacements

      out_fname = File.basename(gly_file).sub(/\.gly\Z/i, '.tex')
      File.open(out_fname, 'w') do |fw|
        fw.puts tex
      end

      system "lualatex #{out_fname}"
    end
  end
end
