require_relative 'test_helper'

class TestMusicWithLyrics < GlyTest
  include Gly

  def assert_translates(gly, expected)
    doc = Parser.new.parse(StringIO.new(gly))
    score = doc.scores[0]
    zipped = MusicWithLyrics.new(score.music, score.lyrics)
    assert_equal zipped.each_pair.to_a, expected
  end

  def two_monosyllabic_words
    assert_translates("a a\n\\l i i", [['a', 'i'], [nil, ' '], ['a', 'i']])
  end

  def test_one_word_and_divisio
    assert_translates("a a ::\nA -- men", [['a', 'A'], ['a', 'men'], [nil, ' '], ['::', nil]])
  end

  def test_divisio
    assert_translates("a , a\n\\l x x", [['a', 'x'], [nil, ' '], [',', nil], [nil, ' '], ['a', 'x']])
  end

  def test_force_under_divisio
    assert_translates("a , a\n\\l x !forced x", [['a', 'x'], [nil, ' '], [',', 'forced'], [nil, ' '], ['a', 'x']])
  end
end
