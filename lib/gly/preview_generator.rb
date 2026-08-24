require 'stringio'

module Gly
  # Takes Gly::Document, builds a pdf preview
  # (or at least generates all necessary assets)
  class PreviewGenerator
    def initialize(template: nil, builder: nil, options: {})
      @template = template || default_template
      @builder = builder || PreviewBuilder.new
      @options = options

      @output_directory = options[:output_directory] || '.'
      @tags = Gly::Tags::Gregorio6.new
    end

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
          score, gabc_fname = scores_with_names.next
          @builder.add_gabc gabc_fname
          fw.puts render_score(score, gabc_fname)
        end
      end

      if @options.has_key? :no_document
        tex = doc_body.string
      else
        replacements = {
          'glyvars' => header_variables(document.header),
          'body' => doc_body.string
        }
        tex = @template.gsub(/\{\{(\w+)\}\}/) {|m| replacements[m[2..-3]] }
      end

      preview_path = File.join(@output_directory, preview_fname(document.path))
      File.open(preview_path, 'w') do |fw|
        @builder.main_tex = preview_fname(document.path)

        fw.puts tex
      end

      return if @options.has_key?(:no_build)

      Dir.chdir @output_directory do
        if @options.has_key?(:no_document)
          @builder.build_gabcs
        else
          @builder.build
        end
      end
    end

    private

    def render_markup(markup)
      markup.text
    end

    def render_score(score, gabc_fname)
      r = StringIO.new

      if @options[:full_headers]
        r.puts header_table score.headers
      end

      piece_title = %w(id book manuscript arranger author).collect do |m|
        val = score.headers[m]
        val = "\\texttt{\\##{val}}" if val && m == 'id'
        val
      end.delete_if(&:nil?).join ', '
      r.puts @tags.commentary(piece_title) unless piece_title.empty?

      gtex_fname = gabc_fname.sub(/\.gabc$/, '.gtex')
      r.puts @tags.score(gtex_fname)

      r.string
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
