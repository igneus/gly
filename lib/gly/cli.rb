require 'thor'

module Gly
  class CLI < Thor
    desc 'gabc FILE ...', 'convert gly to gabc'
    def gabc(*files)
      files.each {|f| gabc_convert f }
    end

    desc 'preview FILE ...', 'convert to gabc AND generate pdf preview'
    def preview(*files)
      files.each {|f| make_preview f }
    end

    private

    def gabc_convert(gly_file)
      parsed = File.open(gly_file) do |fr|
        Parser.new.parse(fr).each_with_index do |score, si|
          score_id = score.headers['id'] || si.to_s
          out_fname = File.basename(gly_file)
                      .sub(/\.gly\Z/i, "_#{score_id}.gabc")
          File.open(out_fname, 'w') do |fw|
            GabcConvertor.new.convert score, fw
          end
          yield score, out_fname if block_given?
        end
      end

    end

    def make_preview(gly_file)
      tex_header = <<EOS
% LuaLaTeX

\\documentclass[a4paper, 12pt]{article}
\\usepackage[latin]{babel}
\\usepackage[left=2cm, right=2cm, top=2cm, bottom=2cm]{geometry}

\\usepackage{fontspec}
\\setmainfont{Junicode}

% for gregorio
\\usepackage{luatextra}
\\usepackage{graphicx}
\\usepackage{gregoriotex}

\\begin{document}

EOS

      tex_fname = File.basename(gly_file).sub(/\.gly\Z/i, '.tex')
      File.open(tex_fname, 'w') do |fw|
        fw.puts tex_header

        gabc_convert(gly_file) do |score, gabc_fname|
          system "gregorio #{gabc_fname}"
          gtex_fname = gabc_fname.sub /\.gabc/i, ''
          fw.puts "\\includescore{#{gtex_fname}}"
        end

        fw.puts "\n\\end{document}"
      end

      system "lualatex #{tex_fname}"
    end
  end
end
