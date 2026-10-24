require_relative 'test_helper'

# Examples are medium-level tests (not unittests, not end-to-end tests)
# testing parser and convertor at the same time.
# Each test case is defined by a pair of a gly and gabc file
# in directories examples/*/given and examples/*/expected.
class TestExamples < GlyTest
  def self.case_name(given_file)
    # filename without extension
    File.basename(given_file).sub(/\.[^\.]*\Z/, '')
  end

  def self.example_test_case(given_file, expected_file)
    define_method "test_#{case_name(given_file)}" do
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
  Dir.glob(File.join(TEST_DIR, 'examples/gly/given/*.gly')).each do |given|
    expected = given.sub('/given', '/expected').sub('.gly', '.gabc')
    example_test_case given, expected
  end

  def transform(fr)
    gly_process(fr).string
  end
end

# conversion gabc -> gly
class TestGlyfyExamples < TestExamples
  Dir.glob(File.join(TEST_DIR, 'examples/glyfy/given/*.gabc')).each do |given|
    expected = given.sub('/given', '/expected').sub('.gabc', '.gly')
    example_test_case given, expected
  end

  def transform(fr)
    glyfy_process(fr).string
  end
end

# gly -> zero or more gabc + a LaTeX document
class TestPreviewExamples < TestExamples
  TEMPLATE = File.read File.join(TEST_DIR, *%w(examples preview template.tex))

  attr_reader :tmp_dir

  def setup
    @tmp_dir = "/tmp/gly-test-examples-preview-#{rand(10**5)}"
    assert !Dir.exist?(tmp_dir)
    Dir.mkdir tmp_dir
  end

  def teardown
    FileUtils.rm_rf tmp_dir
  end

  def self.preview_test_case(given_gly_file, expected_dir)
    define_method "test_#{case_name(given_gly_file)}" do
      document = Gly::Parser.new.parse given_gly_file
      opts = {output_directory: tmp_dir, no_build: true}

      Gly::PreviewGenerator
        .new(template: TEMPLATE, options: opts)
        .process(document)

      list_dir(tmp_dir).each do |f|
        assert File.exist? File.join(tmp_dir, f)
        assert_equal file_contents(f, _in: expected_dir),
                     file_contents(f, _in: tmp_dir)
      end

      assert_equal list_dir(expected_dir), list_dir(tmp_dir)
    end
  end

  Dir.glob(File.join(TEST_DIR, 'examples/preview/given/*.gly')).each do |given|
    expected = given.sub('/given', '/expected').sub('.gly', '')
    preview_test_case given, expected
  end

  def list_dir(name)
    Dir
      .glob(['*.tex', '*.gabc'], base: name)
      .sort
  end

  def file_contents(file_name, _in:)
    File.read File.join _in, file_name
  end
end
