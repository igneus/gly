require 'stringio'

module Gly
  # Takes Gly::Document, builds a pdf preview
  # (or at least generates all necessary assets)
  class PreviewGenerator
    def initialize(**options)
      @preview_dest = nil

      @template = options.delete(:template) || default_template
      @builder = options.delete(:builder) || PreviewBuilder.new
      @options = options.delete(:options) || {}
    end

    # IO to which the main LaTeX document should be written.
    # If not set, a file will be created with name based on
    # the source file name.
    attr_accessor :preview_dest

    def process(document)
      convertor = DocumentGabcConvertor.new(document, **@options)
      convertor.convert

      doc_body = fw = StringIO.new

      if @options[:full_headers]
        fw.puts header_table document.header
      end

      scores_with_names = convertor.each_score_with_gabcname

      document.content.each do |c|
        if c.is_a? Markup
          fw.puts render_markup(c)
        else
          score, gabc_fname, gtex_fname = scores_with_names.next
          fw.puts render_score(score, gabc_fname, gtex_fname)
        end
      end

      if @options['no_document']
        tex = doc_body.string
      else
        replacements = {
          'glyvars' => header_variables(document.header),
          'body' => doc_body.string
        }
        tex = @template.gsub(/\{\{(\w+)\}\}/) {|m| replacements[m[2..-3]] }
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

    def render_markup(markup)
      markup.text
    end

    def render_score(score, gabc_fname, gtex_fname)
      r = StringIO.new

      @builder.add_gabc gabc_fname

      if @options[:full_headers]
        r.puts header_table score.headers
      end

      piece_title = %w(id book manuscript arranger author).collect do |m|
        val = score.headers[m]
        val = "\\texttt{\\##{val}}" if val && m == 'id'
        val
      end.delete_if(&:nil?).join ', '
      r.puts "\\commentary{\\footnotesize{#{piece_title}}}\n" unless piece_title.empty?

      annotations = score.headers.each_value('annotation')
      begin
        r.puts "\\setfirstannotation{#{annotations.next}}"
        r.puts "\\setsecondannotation{#{annotations.next}}"
      rescue StopIteration
        # ok, no more annotations
      end

      r.puts "\\includescore{#{gtex_fname}}\n\\vspace{1cm}"

      r.string
    end

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

    # transforms header to LaTeX command definitions
    def header_variables(header)
      header.each_pair.collect do |k,v|
        '\newcommand{\%s}{%s}' % [latex_cmd_name(k), v]
      end.join("\n")
    end

    def latex_cmd_name(header_name)
      sanitized = header_name
                  .gsub(/\s+/, '')
                  .gsub(/[-_]+(\w)/) {|m| m[1].upcase }
      prefixed = 'gly' + sanitized[0].upcase + sanitized[1..-1]
    end
  end
end
