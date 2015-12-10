require_relative 'test_helper'

# tests of cases that cannot be easily described by a pair
# of single gly file and resulting gabc file
class TestNoCrash < GlyTest
  def self.nocrash_test_case(filename)
    case_name = File.basename(filename).sub(/\.[^\.]*\Z/, '')
    define_method "test_#{case_name}" do
      File.open filename do |fr|
        # simply let it convert to test that it does not crash
        gly_process(fr).string
      end
    end
  end

  here = File.dirname __FILE__
  Dir.glob(File.join(here, 'examples/gly/no_crash/*.gly')).each do |f|
    nocrash_test_case f
  end
end
