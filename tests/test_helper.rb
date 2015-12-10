$: << File.expand_path('../lib', File.dirname(__FILE__))
require 'gly'

require 'minitest/autorun'

require 'minitest/reporters'
Minitest::Reporters.use!

# parent of all gly test classes
class GlyTest < MiniTest::Test
  # shortcut performing gly->gabc conversion and returning
  # it's results
  def gly_process(gly_io)
    parsed = Gly::Parser.new.parse(gly_io).first
    Gly::GabcConvertor.new.convert(parsed)
  end
end
