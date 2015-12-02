# test-suite dynamically created from examples in subfolders

require_relative 'test_helper'

def gly_process(s)
  # for now do nothing
  s
end

def create_gly_test_case(given_file, expected_file)
  # filename without extension
  case_name = File.basename(given_file).sub(/\.[^\.]*\Z/, '')

  test_case = Class.new(MiniTest::Test) do |klass|
    define_method "test_#{case_name}" do
      given = File.read given_file
      expected = File.read expected_file
      assert_equal expected, gly_process(given)
    end
  end

  # make CamelCase
  class_name = case_name.gsub(/(^|_)(\w)/) {|m| m[-1].upcase }
  Object.const_set class_name, test_case
end

here = File.dirname __FILE__
Dir.glob(File.join(here, 'examples/gly/**/*.gly')).each do |given|
  expected = given.sub('/given', '/expected').sub('.gly', '.gabc')
  create_gly_test_case given, expected
end
