#!/usr/bin/ruby
require 'test/unit'
require 'docdiff'
require 'nkf'
require 'uconv'

class TC_Document < Test::Unit::TestCase

  def setup()
    #
  end

  def test_compare_by_line()
    doc1 = Document.new("Foo bar.\nBaz quux.")
    doc1.encoding = 'ASCII'
    docdiff = DocDiff.new
    doc1.eol = 'LF'
    doc2 = Document.new("Foo.\nBaz quux.")
    doc2.encoding = 'ASCII'
    doc2.eol = 'LF'
    expected = [[:change_elt,     ["Foo bar.\n"], ["Foo.\n"]],
                [:common_elt_elt, ['Baz quux.'], ['Baz quux.']]]
    assert_equal(expected, docdiff.compare_by_line(doc1, doc2))
  end
  def test_compare_by_word()
    doc1 = Document.new("a b c d\ne f")
    doc1.encoding = 'ASCII'
    docdiff = DocDiff.new
    doc1.eol = 'LF'
    doc2 = Document.new("a x c d\ne f")
    doc2.encoding = 'ASCII'
    doc2.eol = 'LF'
    expected = [[:common_elt_elt, ["a "], ["a "]],
                [:change_elt,     ["b "], ["x "]],
                [:common_elt_elt, ["c ", "d", "\n"], ["c ", "d", "\n"]],
                [:common_elt_elt, ["e f"], ["e f"]]]
    assert_equal(expected, docdiff.compare_by_word(doc1, doc2))
  end
  def test_compare_by_char()
    doc1 = Document.new("foo bar\nbaz")
    doc1.encoding = 'ASCII'
    doc1.eol = 'LF'
    docdiff = DocDiff.new
    doc2 = Document.new("foo beer\nbaz")
    doc2.encoding = 'ASCII'
    doc2.eol = 'LF'
    expected = [[:common_elt_elt, ['foo '], ['foo ']],
                [:common_elt_elt, ['b'], ['b']],
                [:change_elt,     ['a'], ['e', 'e']],
                [:common_elt_elt, ['r'], ['r']],
                [:common_elt_elt, ["\n"], ["\n"]],
                [:common_elt_elt, ['baz'], ['baz']]]
    assert_equal(expected, docdiff.compare_by_char(doc1, doc2))
  end

  def teardown()
    #
  end

end
