require_relative 'test_helper'

class TagsTest < MiniTest::Test
  # save some typing
  V = Gem::Version
  Gregorio4 = Gly::Tags::Gregorio4
  Gregorio5 = Gly::Tags::Gregorio5

  examples = [
    ['gregorio4', V.new('4'), Gregorio4],
    ['gregorio4_semantic', V.new('4.1.2'), Gregorio4],
    ['gregorio5', V.new('5'), Gregorio5],
    # integer works, too
    ['integer_4', 4, Gregorio4],
    ['integer_5', 5, Gregorio5],
    # for older versions Gregorio 4 strategy is used
    ['gregorio1', V.new('1'), Gregorio4],
    ['gregorio2', V.new('2'), Gregorio4],
    ['gregorio3', V.new('3'), Gregorio4],
    # for versions newer than 5 use Gregorio 5 strategy
    ['gregorio6', V.new('6'), Gregorio5],
  ]

  examples.each do |e|
    name, given, expected = e
    define_method "test_#{name}" do
      assert_kind_of expected, Gly::Tags[given]
    end
  end

  invalid_examples = [
    ['nil', nil],
    ['string', '1.1.0'],
  ]

  invalid_examples.each do |e|
    name, given = e
    define_method "test_invalid_#{name}" do
      assert_raises ArgumentError do
        Gly::Tags[given]
      end
    end
  end
end
