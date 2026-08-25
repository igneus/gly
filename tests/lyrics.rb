require_relative 'test_helper'

class TestLyrics < GlyTest
  include Gly

  EOW = Lyrics::END_OF_WORD
  EOL = Lyrics::END_OF_LINE

  def assert_translates(gly, expected)
    doc = Parser.new.parse(StringIO.new(gly))
    lyrics = doc.scores[0].lyrics
    assert_equal expected, lyrics.each_syllable.to_a
  end

  def test_two_monosyllabic_words
    assert_translates(
      '\l i i',
      [['i', EOW], ['i', EOL]]
    )
  end

  def test_one_word
    assert_translates(
      '\l A -- men',
      [['A', nil], ['men', EOL]]
    )
  end

  def test_two_words
    assert_translates(
      '\l A -- men, a -- men.',
      [['A', nil], ['men,', EOW], ['a', nil], ['men.', EOL]]
    )
  end
end
