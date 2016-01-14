# test-suite dynamically created from examples in subfolders

require_relative 'test_helper'

# Each test case is defined by a pair of files
# in directories examples/given and examples/expected
class TestExamples < GlyTest
  def self.example_test_case(given_file, expected_file)
    # filename without extension
    case_name = File.basename(given_file).sub(/\.[^\.]*\Z/, '')

    define_method "test_#{case_name}" do
      expected = File.read expected_file
      File.open given_file do |fr|
        # the method transform is 'deferred'
        # for implementation in subclasses
        given = transform fr
        assert_equal expected, given
      end
    end
  end
end

# conversion gly -> gabc
class TestGlyExamples < TestExamples
  here = File.dirname __FILE__
  Dir.glob(File.join(here, 'examples/gly/given/*.gly')).each do |given|
    expected = given.sub('/given', '/expected').sub('.gly', '.gabc')
    example_test_case given, expected
  end

  def transform(fr)
    gly_process(fr).string
  end
end

# conversion gabc -> gly
class TestGlyfyExamples < TestExamples
  here = File.dirname __FILE__
  Dir.glob(File.join(here, 'examples/glyfy/given/*.gabc')).each do |given|
    expected = given.sub('/given', '/expected').sub('.gabc', '.gly')
    example_test_case given, expected
  end

  def transform(fr)
    glyfy_process(fr).string
  end
end
