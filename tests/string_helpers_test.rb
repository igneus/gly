require_relative 'test_helper'

class StringHelpersTest < GlyTest
  SH = Gly::StringHelpers

  examples = [
    ['single_chunk', 'a', ['a']],
    ['simple_whitespace', 'aa aa', ['aa', 'aa']],
    ['leading_trailing_whitespace', ' a a  ', ['a', 'a']],
    ['repeated_inner_whitespace', 'a    a', ['a', 'a']],
    ['bracketted', '(a)', ['a']],
    ['empty', '()', ['']],
    ['nested', '(a(b))', ['a(b', ')']] # nesting isn't supported
  ]

  examples.each do |e|
    name, given, expected = e
    define_method "test_#{name}" do
      assert_equal expected, SH.music_split(given)
    end
  end
end
