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
    doc1 = Document.new("Foo bar.\nBaz quux.", 'ASCII', 'LF')
    doc2 = Document.new("Foo.\nBaz quux.", 'ASCII', 'LF')
    docdiff = DocDiff.new
    expected = [[:change_elt,     ["Foo bar.\n"], ["Foo.\n"]],
                [:common_elt_elt, ['Baz quux.'], ['Baz quux.']]]
    assert_equal(expected, docdiff.compare_by_line(doc1, doc2))
  end
  def test_compare_by_word()
    doc1 = Document.new("a b c d\ne f", 'ASCII', 'LF')
    doc2 = Document.new("a x c d\ne f", 'ASCII', 'LF')
    docdiff = DocDiff.new
    expected = [[:common_elt_elt, ["a "], ["a "]],
                [:change_elt,     ["b "], ["x "]],
                [:common_elt_elt, ["c ", "d", "\n"], ["c ", "d", "\n"]],
                [:common_elt_elt, ["e f"], ["e f"]]]
    assert_equal(expected, docdiff.compare_by_word(doc1, doc2))
  end
  def test_compare_by_char()
    doc1 = Document.new("foo bar\nbaz", 'ASCII', 'LF')
    doc2 = Document.new("foo beer\nbaz", 'ASCII', 'LF')
    docdiff = DocDiff.new
    expected = [[:common_elt_elt, ['foo '], ['foo ']],
                [:common_elt_elt, ['b'], ['b']],
                [:change_elt,     ['a'], ['e', 'e']],
                [:common_elt_elt, ['r'], ['r']],
                [:common_elt_elt, ["\n"], ["\n"]],
                [:common_elt_elt, ['baz'], ['baz']]]
    assert_equal(expected, docdiff.compare_by_char(doc1, doc2))
  end

  def test_run_line_manued()
    doc1 = Document.new("foo bar\nbaz", 'ASCII', 'LF')
    doc2 = Document.new("foo beer\nbaz", 'ASCII', 'LF')
    docdiff = DocDiff.new
    expected = "[foo bar\n/foo beer\n]baz"
    assert_equal(expected, docdiff.run(doc1, doc2, :line, :manued))
  end
  def test_run_word_manued()
    doc1 = Document.new("foo bar\nbaz", 'ASCII', 'LF')
    doc2 = Document.new("foo beer\nbaz", 'ASCII', 'LF')
    docdiff = DocDiff.new
    expected = "foo [bar/beer]\nbaz"
    assert_equal(expected, docdiff.run(doc1, doc2, :word, :manued))
  end
  def test_run_char_manued()
    doc1 = Document.new("foo bar\nbaz", 'ASCII', 'LF')
    doc2 = Document.new("foo beer\nbaz", 'ASCII', 'LF')
    docdiff = DocDiff.new
    expected = "foo b[a/ee]r\nbaz"
    assert_equal(expected, docdiff.run(doc1, doc2, :char, :manued))
  end

  def test_parse_config_file_content()
    content = ["# comment line\n",
               " # comment line\n",
               "foo1 = bar\n",
               "foo2 = bar baz \n",
               " f o o 3  =  bar # comment\n",
               "foo1 = quux\n",
               "\n",
               "",
               nil].to_s
    expected = {"foo1"=>"quux", "foo2"=>"bar baz", "f o o 3"=>"bar"}
    docdiff = DocDiff.new
    assert_equal(expected, DocDiff.parse_config_file_content(content))
  end

  def teardown()
    #
  end

end
