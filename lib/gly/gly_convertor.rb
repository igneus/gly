module Gly
  # converts gabc to gly
  class GlyConvertor
    # score - GabcScore (from the lygre gem)
    def convert(score, out=StringIO.new)
      out.puts '\score'
      out.puts header score
      out.puts music score
      out.puts lyrics score
      out
    end

    def header(score)
      score.header.each_pair.collect do |key,value|
        "#{key}: #{value}"
      end.join "\n"
    end

    def music(score)
      score.music.words.collect do |word|
        word.each_syllable.collect do |syl|
          syl = syl.notes.collect(&:text_value).join ''
          if syl.include? ' ' || syl.empty?
            syl = "(#{syl})"
          end
          syl
        end.join ' '
      end.flatten.join ' '
    end

    def lyrics(score)
      score.music.words.collect {|w| word w }.join ' '
    end

    def word(word)
      word.each_syllable.collect {|s| s.lyrics }.join ' -- '
    end
  end
end
