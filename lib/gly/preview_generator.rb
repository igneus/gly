require 'stringio'

module Gly
  # Takes Gly::Document, builds a pdf preview
  # (or at least generates all necessary assets)
  class PreviewGenerator
    def initialize(template: nil, builder: nil, options: {})
      @preview_dest = nil

      @template = template || default_template
      @builder = builder || PreviewBuilder.new
      @options = options
    end

    # IO to which the main LaTeX document should be written.
    # If not set, a file will be created with name based on
    # the source file name.
    attr_accessor :preview_dest

    def process(document)
      convertor = DocumentGabcConvertor.new(document)
      convertor.convert

      doc_body = fw = StringIO.new

      if @options[:full_headers]
        fw.puts header_table document.header
      end

      convertor.each_score_with_gabcname do |score, gabc_fname|
        @builder.add_gabc gabc_fname

        if @options[:full_headers]
          fw.puts header_table score.headers
        end

        gtex_fname = gabc_fname.sub /\.gabc/i, ''
        piece_title = %w(book manuscript arranger author).collect do |m|          score.headers[m]
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

      if @options['no_document']
        tex = doc_body.string
      else
        replacements = {
          title: document.header['title'],
          maketitle: (document.header['title'] && '\maketitle'),
          body: doc_body.string
        }
        tex = @template % replacements
      end

      with_preview_io(document.path) do |fw|
        @builder.main_tex = fw.path if fw.respond_to? :path

        fw.puts tex
      end

      build_disabled = @options['no_build'] || @options['no_document']
      if @builder.main_tex && !build_disabled
        @builder.build
      end
    end

    private

    def with_preview_io(src_name)
      if @preview_dest
        yield @preview_dest
        return
      end

      File.open(preview_fname(src_name), 'w') do |fw|
        yield fw
      end
    end

    def preview_fname(src_name)
      File.basename(src_name).sub(/\.gly\Z/i, '.tex')
    end

    def default_template
      File.read(File.join(File.dirname(__FILE__), 'templates/lualatex_document.tex'))
    end

    # full header of a score/file as table
    def header_table(header)
      return '' if header.empty?

      cols = header.each_pair.collect {|k,v| "#{k} & #{v} \\\\" }

      "\\begin{tabular}{ | r | l | } \\hline %s \\hline \\end{tabular}\n\n" % cols.join("\\hline\n")
    end
  end
end
