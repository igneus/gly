require_relative 'test_helper'

class TestParser < GlyTest
  def test_markup_after_header
    doc = nil
    File.open expand_test_path('examples/parser/markup_after_header.gly') do |fr|
      doc = Gly::Parser.new.parse(fr)
    end
    assert_equal 1, doc.header.size
    assert doc.header.has_key?('title')
  end

  def test_markups
    doc = nil
    File.open expand_test_path('examples/parser/markups.gly') do |fr|
      doc = Gly::Parser.new.parse(fr)
    end

    assert doc.scores.empty?

    assert_equal "Perhaps", doc.content[0].text
    assert_equal "Ave\nCaesar", doc.content[1].text
    assert_equal "Ave Crux\n\nspes unica", doc.content[2].text
  end
end
