module Gly
  # Contains "strategies" for generation of GregorioTeX
  # commands depending on Gregorio version.
  module Tags
    # Receives Gregorio version (as `Gem::Version` instance or number),
    # returns strategy instance.
    def self.[](version)
      is4 =
        if version.is_a?(Gem::Version)
          Gem::Version.new('5') > version
        else
          5 > version
        end

      if is4
        return Gregorio4.new
      end

      return Gregorio5.new
    end

    class Gregorio4
      def commentary(str)
        "\\commentary{\\footnotesize{#{str}}}\n"
      end

      def annotations(first, second)
        "\\setfirstannotation{#{first}}" +
          "\\setsecondannotation{#{second}}"
      end

      def score(filename)
        # TODO: space between scores should not be hardcoded this way
        "\\includescore{#{filename}}\n\\vspace{1cm}"
      end
    end

    class Gregorio5
      def commentary(str)
        "\\grecommentary{\\footnotesize{#{str}}}\n"
      end

      def annotations(first, second)
        "\\greannotation{#{first}}" +
          "\\greannotation{#{second}}"
      end

      def score(filename)
        # TODO: space between scores should not be hardcoded this way
        "\\gregorioscore{#{filename}}\n\\vspace{1cm}"
      end
    end
  end
end
