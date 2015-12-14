require 'thor'

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

    private

    def parse(gly_file)
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

      tex_header = <<EOS
% LuaLaTeX

\\documentclass[a4paper, 12pt]{article}
\\usepackage[latin]{babel}
\\usepackage[left=2cm, right=2cm, top=2cm, bottom=2cm]{geometry}

\\usepackage{fontspec}

% for gregorio
\\usepackage{luatextra}
\\usepackage{graphicx}
\\usepackage{gregoriotex}

\\newcommand{\\pieceTitle}[1]{\\begin{flushright}\\footnotesize{#1}\\end{flushright}}

\\title{#{doc.header['title']}}

\\begin{document}

#{doc.header['title'] && '\\maketitle'}

EOS

      tex_fname = File.basename(gly_file).sub(/\.gly\Z/i, '.tex')
      File.open(tex_fname, 'w') do |fw|
        fw.puts tex_header

        gabc_convert(doc) do |score, gabc_fname|
          system "gregorio #{gabc_fname}"
          gtex_fname = gabc_fname.sub /\.gabc/i, ''
          piece_title = %w(book manuscript arranger author).collect do |m|
            score.headers[m]
          end.delete_if(&:nil?).join ', '
          fw.puts "\\pieceTitle{#{piece_title}}"
          fw.puts
          fw.puts "\\includescore{#{gtex_fname}}\n\\vspace{1cm}"
        end

        # tagline
        fw.puts "\n\\vfill\n\\begin{center}"
        fw.puts "\\texttt{gly preview https://github.com/igneus/gly}"
        fw.puts "\\end{center}\n"
        fw.puts "\n\\end{document}"
      end

      system "lualatex #{tex_fname}"
    end
  end
end
