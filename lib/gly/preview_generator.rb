require 'stringio'

module Gly
  # Takes Gly::Document, builds a pdf preview
  # (or at least generates all necessary assets)
  class PreviewGenerator
    def process(document)
      tpl_name = File.join(File.dirname(__FILE__), 'templates/lualatex_document.tex')
      template = File.read(tpl_name)

      doc_body = fw = StringIO.new

      convertor = DocumentGabcConvertor.new(document)
      convertor.each_score_with_gabcname do |score, gabc_fname|
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
        title: document.header['title'],
        maketitle: (document.header['title'] && '\maketitle'),
        body: doc_body.string
      }
      tex = template % replacements

      out_fname = File.basename(document.path).sub(/\.gly\Z/i, '.tex')
      File.open(out_fname, 'w') do |fw|
        fw.puts tex
      end

      system "lualatex #{out_fname}"
    end
  end
end
