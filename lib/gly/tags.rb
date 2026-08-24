module Gly
  # Contains "strategies" for generation of GregorioTeX
  # commands depending on Gregorio version.
  module Tags
    class Gregorio6
      def commentary(str)
        "\\grecommentary{\\footnotesize{#{str}}}\n"
      end

      def score(filename)
        # TODO: space between scores should not be hardcoded this way
        "\\gregorioscore{#{filename}}\n\\vspace{1cm}"
      end
    end
  end
end
