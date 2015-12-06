require 'forwardable'

module Gly
  class Lyrics
    extend Forwardable

    def initialize
      @words = []
    end

    def each_syllable
      return enum_for(:each_syllable) unless block_given?

      @words.each do |w|
        w.each_syllable.each_with_index do |s,si|
          if si == 0
            yield ' ' + s
          else
            yield s
          end
        end
      end
    end

    def_delegator :@words, :each, :each_word
    def_delegators :@words, :empty?, :<<
  end

  class Word
    extend Forwardable

    def initialize(syllables=[])
      @syllables = syllables
    end

    def_delegators :@syllables, :<<, :push
    def_delegator :@syllables, :each, :each_syllable
  end
end
