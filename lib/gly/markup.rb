module Gly
  class Markup
    def initialize(text='')
      @text = text
    end

    def text
      @text.strip
    end

    def <<(line)
      @text += line
    end
  end
end
