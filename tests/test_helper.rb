$: << File.expand_path('../lib', File.dirname(__FILE__))
require 'gly'

begin
  require 'grely'
rescue LoadError
end

require 'minitest/autorun'

require 'minitest/reporters'
Minitest::Reporters.use!

# parent of all gly test classes
class GlyTest < MiniTest::Test
  # shortcut performing gly->gabc conversion and returning
  # it's results
  def gly_process(gly_io)
    doc = Gly::Parser.new.parse(gly_io)
    Gly::GabcConvertor.new.convert(doc.scores[0])
  end

  def glyfy_process(gabc_io)
    unless defined? GabcParser
      skip 'lygre not found, cannot run glyfy tests'
    end

    parsing_result = GabcParser.new.parse gabc_io.read
    score = parsing_result.create_score
    Gly::GlyConvertor.new.convert score
  end
end
