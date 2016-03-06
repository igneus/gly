require_relative 'test_helper'

class TestParser < GlyTest
  def test_markup_after_header
    doc = parse_example 'examples/parser/markup_after_header.gly'
    assert_equal 1, doc.header.size
    assert doc.header.has_key?('title')
  end

  def test_markups
    doc = parse_example 'examples/parser/markups.gly'

    assert doc.scores.empty?

    assert_equal "Perhaps", doc.content[0].text
    assert_equal "Ave\nCaesar", doc.content[1].text
    assert_equal "Ave Crux\n\nspes unica", doc.content[2].text
  end

  def test_score_markup_order
    doc = parse_example 'examples/parser/score_markup_order.gly'

    assert_equal 6, doc.content.size

    assert_instance_of Gly::ParsedScore, doc.content[0]
    assert_equal 'a', doc.content[0].headers['id']

    assert_instance_of Gly::Markup, doc.content[1]
    assert_equal 'a', doc.content[1].text

    assert_instance_of Gly::ParsedScore, doc.content[2]
    assert_equal 'b', doc.content[2].headers['id']

    assert_instance_of Gly::Markup, doc.content[3]
    assert_equal 'b', doc.content[3].text

    assert_instance_of Gly::Markup, doc.content[4]
    assert_equal 'c', doc.content[4].text

    assert_instance_of Gly::ParsedScore, doc.content[5]
    assert_equal 'c', doc.content[5].headers['id']
  end

  def parse_example(path)
    doc = nil
    File.open expand_test_path(path) do |fr|
      doc = Gly::Parser.new.parse(fr)
    end
    doc
  end
end
