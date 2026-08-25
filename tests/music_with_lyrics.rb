require_relative 'test_helper'

class TestMusicWithLyrics < GlyTest
  include Gly

  EOW = Lyrics::END_OF_WORD
  EOL = Lyrics::END_OF_LINE

  def assert_translates(gly, expected)
    doc = Parser.new.parse(StringIO.new(gly))
    score = doc.scores[0]
    zipped = MusicWithLyrics.new(score.music, score.lyrics)
    assert_equal expected, zipped.each_pair.to_a
  end

  def test_two_monosyllabic_words
    assert_translates(
      "a a\n\\l i i",
      [['a', 'i', EOW], ['a', 'i', EOL]]
    )
  end

  def test_one_word_and_divisio
    assert_translates(
      "a a ::\nA -- men",
      [['a', 'A', nil], ['a', 'men', EOL], ['::', nil, EOW]]
    )
  end

  def test_divisio
    assert_translates(
      "a , a\n\\l x x",
      [['a', 'x', EOW], [',', nil, EOW], ['a', 'x', EOL]]
    )
  end

  def test_force_under_divisio
    assert_translates(
      "a , a\n\\l x !forced x",
      [['a', 'x', EOW], [',', 'forced', EOW], ['a', 'x', EOL]]
    )
  end

  def test_clef
    assert_translates(
      "c3",
      [['c3', nil, EOW]]
    )
  end
end
