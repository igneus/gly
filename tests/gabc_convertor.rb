require_relative 'test_helper'

describe Gly::GabcConvertor do
  def c(**options)
    lambda do |score|
      Gly::GabcConvertor
        .new(options)
        .convert(score)
        .string
    end
  end

  def gly_score(source)
    Gly::Parser.new.parse_str(source).scores[0]
  end

  describe 'line breaking options' do
    before do
      @long = gly_score <<~GLY
      h h h hih, h h h g ,
      A -- men a -- men di -- co vo -- bis:
      GLY
    end

    it 'by default produces a long one-line gabc' do
      _(c.(@long)).must_equal <<~GABC
      %%
      A(h)men(h) a(h)men(hih,) di(h)co(h) vo(h)bis:(g) (,)
      GABC
    end

    it 'break_words wraps line after each gabc word' do
      _(c(break_words: true).(@long)).must_equal <<~GABC
      %%
      A(h)men(h)
      a(h)men(hih,)
      di(h)co(h)
      vo(h)bis:(g)
      (,)
      GABC
    end

    it 'break_divisiones wraps line after each divisio' do
      _(c(break_divisiones: true).(@long)).must_equal <<~GABC
      %%
      A(h)men(h) a(h)men(hih,)
      di(h)co(h) vo(h)bis:(g) (,)
      GABC
    end

    it 'break_divisiones and divisio in the middle of a word' do
      score = gly_score <<~GLY
      h, h
      a -- men
      GLY
      # Line breaking strategy must never change semantics.
      # Here breaking line on divisio would break a word in two.
      _(c(break_divisiones: true).(score)).must_equal <<~GABC
      %%
      a(h,)men(h)
      GABC
    end

    it 'break_words + break_divisiones' do
      _(c(break_words: true, break_divisiones: true).(@long)).must_equal <<~GABC
      %%
      A(h)men(h)
      a(h)men(hih,)
      di(h)co(h)
      vo(h)bis:(g)
      (,)
      GABC
    end

    it 'break_lines' do
      _(c(break_lines: true).(gly_score(<<~GLY))).must_equal <<~GABC
      h h h hih, h h , ; h g ,
      A -- men a -- men
      di -- co
      vo -- bis:
      GLY
      %%
      A(h)men(h) a(h)men(hih,)
      di(h)co(h) (,) (;)
      vo(h)bis:(g) (,)
      GABC
    end
  end

  describe 'comment_headers option' do
    before do
      @long = gly_score <<~GLY
      name: Salva nos
      mode: 3
      custom-field: value
      GLY
    end

    it 'by default comments out header fields unsupported by Gregorio' do
      _(c.(@long)).must_equal <<~GABC
      name: Salva nos;
      mode: 3;
      % custom-field: value;
      %%
      GABC
    end

    it 'can be opted out from the commenting' do
      _(c(comment_headers: false).(@long)).must_equal <<~GABC
      name: Salva nos;
      mode: 3;
      custom-field: value;
      %%
      GABC
    end
  end
end
