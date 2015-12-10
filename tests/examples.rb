# test-suite dynamically created from examples in subfolders

require_relative 'test_helper'

# Each test case is defined by a pair of files
# in directories examples/given and examples/expected
# which define what is an expected gabc result of a single-score
# gly file.
class TestExamples < GlyTest
  def self.example_test_case(given_file, expected_file)
    # filename without extension
    case_name = File.basename(given_file).sub(/\.[^\.]*\Z/, '')

    define_method "test_#{case_name}" do
      expected = File.read expected_file
      File.open given_file do |fr|
        assert_equal expected, gly_process(fr).string
      end
    end
  end

  here = File.dirname __FILE__
  Dir.glob(File.join(here, 'examples/gly/given/*.gly')).each do |given|
    expected = given.sub('/given', '/expected').sub('.gly', '.gabc')
    example_test_case given, expected
  end
end
