require_relative 'test_helper'

class TestParser < GlyTest
  def test_markup_after_header
    doc = nil
    File.open expand_test_path('examples/parser/markup_after_header.gly') do |fr|
      doc = Gly::Parser.new.parse(fr)
    end
    assert_equal 1, doc.header.size
    assert doc.header.has_key?('titl')
  end
end
