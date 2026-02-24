#!/usr/bin/ruby
# -*- coding: utf-8; -*-

# frozen_string_literal: false

require "test/unit"
require "docdiff/document"
require "nkf"

class TestDocument < Test::Unit::TestCase
  Document = DocDiff::Document
  CharString = DocDiff::CharString

  def setup
  end

  def test_encoding
    doc = Document.new("Foo bar.\nBaz quux.")
    doc.encoding = "US-ASCII"
    doc.eol = "LF"
    expected = "US-ASCII"
    assert_equal(expected, doc.encoding)
  end

  def test_encoding_auto
    doc = Document.new("Foo bar.\nBaz quux.".encode("US-ASCII"))
    expected = "US-ASCII"
    assert_equal(expected, doc.encoding)
  end

  def test_eol
    doc = Document.new("Foo bar.\nBaz quux.")
    doc.encoding = "US-ASCII"
    doc.eol = "LF"
    expected = "LF"
    assert_equal(expected, doc.eol)
  end

  def test_eol_auto_lf
    doc = Document.new("Foo bar.\nBaz quux.")
    expected = "LF"
    assert_equal(expected, doc.eol)
  end

  def test_eol_auto_none
    doc = Document.new("Foo bar.")
    expected = "NONE"
    assert_equal(expected, doc.eol)
  end

  def test_eol_char_lf
    doc = Document.new("Foo bar.\nBaz quux.")
    # doc.encoding = "US-ASCII"
    # doc.eol = "LF"
    expected = "\n"
    assert_equal(expected, doc.eol_char)
  end

  def test_split_to_lines
    doc = Document.new("Hello, my name is Watanabe.\nI am just another Ruby porter.\n")
    expected = ["Hello, my name is Watanabe.\n", "I am just another Ruby porter.\n"]
    assert_equal(expected, doc.split_to_lines)
  end

  # test eol split_to_lines method
  def test_cr_split_to_lines
    doc = Document.new("foo\rbar\r")
    expected = ["foo\r", "bar\r"]
    assert_equal(expected, doc.split_to_lines)
  end

  def test_cr_split_to_lines_chomped_lastline
    doc = Document.new("foo\rbar")
    expected = ["foo\r", "bar"]
    assert_equal(expected, doc.split_to_lines)
  end

  def test_cr_split_to_lines_empty_line
    doc = Document.new("foo\r\rbar\r")
    expected = ["foo\r", "\r", "bar\r"]
    assert_equal(expected, doc.split_to_lines)
  end

  def test_lf_split_to_lines
    doc = Document.new("foo\nbar\n")
    expected = ["foo\n", "bar\n"]
    assert_equal(expected, doc.split_to_lines)
  end

  def test_lf_split_to_lines_chomped_lastline
    doc = Document.new("foo\nbar")
    expected = ["foo\n", "bar"]
    assert_equal(expected, doc.split_to_lines)
  end

  def test_lf_split_to_lines_empty_line
    doc = Document.new("foo\n\nbar\n")
    expected = ["foo\n", "\n", "bar\n"]
    assert_equal(expected, doc.split_to_lines)
  end

  def test_crlf_split_to_lines
    doc = Document.new("foo\r\nbar\r\n")
    expected = ["foo\r\n", "bar\r\n"]
    assert_equal(expected, doc.split_to_lines)
  end

  def test_crlf_split_to_lines_chomped_lastline
    doc = Document.new("foo\r\nbar")
    expected = ["foo\r\n", "bar"]
    assert_equal(expected, doc.split_to_lines)
  end

  def test_crlf_split_to_lines_empty_line
    doc = Document.new("foo\r\n\r\nbar\r\n")
    expected = ["foo\r\n", "\r\n", "bar\r\n"]
    assert_equal(expected, doc.split_to_lines)
  end

  # test ASCII module
  def test_ascii_split_to_words
    doc = Document.new("foo bar")
    expected = ["foo ", "bar"]
    assert_equal(expected, doc.split_to_words)
  end

  def test_ascii_split_to_words_withsymbol
    doc = Document.new("foo (bar) baz-baz")
    expected = ["foo ", "(bar) ", "baz-baz"]
    assert_equal(expected, doc.split_to_words)
  end

  def test_ascii_split_to_words_withquote
    doc = Document.new("foo's 'foo' \"bar\" 'baz.'")
    expected = ["foo's ", "'foo' ", "\"bar\" ", "'baz.'"]
    assert_equal(expected, doc.split_to_words)
  end

  def test_ascii_split_to_words_withlongspace
    doc = Document.new(" foo  bar")
    expected = [" ", "foo ", " ", "bar"]
    assert_equal(expected, doc.split_to_words)
  end

  def test_ascii_split_to_words_withdash
    doc = Document.new("foo -- bar, baz - quux")
    expected = ["foo ", "-- ", "bar, ", "baz ", "- ", "quux"]
    assert_equal(expected, doc.split_to_words)
  end

  def test_ascii_split_to_chars
    doc = Document.new("foo bar")
    expected = ["f", "o", "o", " ", "b", "a", "r"]
    assert_equal(expected, doc.split_to_chars)
  end

  def test_ascii_split_to_chars_with_eol_cr
    doc = Document.new("foo bar\r")
    expected = ["f", "o", "o", " ", "b", "a", "r", "\r"]
    assert_equal(expected, doc.split_to_chars)
  end

  def test_ascii_split_to_chars_with_eol_lf
    doc = Document.new("foo bar\n")
    expected = ["f", "o", "o", " ", "b", "a", "r", "\n"]
    assert_equal(expected, doc.split_to_chars)
  end

  def test_ascii_split_to_chars_with_eol_crlf
    doc = Document.new("foo bar\r\n")
    expected = ["f", "o", "o", " ", "b", "a", "r", "\r\n"]
    assert_equal(expected, doc.split_to_chars)
  end

  def test_ascii_split_to_bytes
    doc = Document.new("foo bar\r\n")
    expected = ["f", "o", "o", " ", "b", "a", "r", "\r", "\n"]
    assert_equal(expected, doc.split_to_bytes)
  end

  def test_ascii_count_bytes
    doc = Document.new("foo bar\r\n")
    expected = 9
    assert_equal(expected, doc.count_bytes)
  end

  def test_ascii_count_chars
    doc = Document.new("foo bar\r\nbaz quux\r\n")
    expected = 17
    assert_equal(expected, doc.count_chars)
  end

  def test_ascii_count_latin_graph_chars
    doc = Document.new("foo bar\r\nbaz quux\r\n")
    expected = 13
    assert_equal(expected, doc.count_latin_graph_chars)
  end

  def test_ascii_count_graph_chars
    doc = Document.new("foo bar\r\nbaz quux\r\n")
    expected = 13
    assert_equal(expected, doc.count_graph_chars)
  end

  def test_ascii_count_latin_blank_chars
    doc = Document.new("foo bar\r\nbaz\tquux\r\n")
    expected = 2
    assert_equal(expected, doc.count_latin_blank_chars)
  end

  def test_ascii_count_blank_chars
    doc = Document.new("foo bar\r\nbaz\tquux\r\n")
    expected = 2
    assert_equal(expected, doc.count_blank_chars)
  end

  def test_ascii_count_words
    doc = Document.new("foo bar   \r\nbaz quux\r\n")
    expected = 6
    assert_equal(expected, doc.count_words)
  end

  def test_ascii_count_latin_words
    doc = Document.new("foo bar   \r\nbaz quux\r\n")
    expected = 5 # "  " is also counted as a word
    assert_equal(expected, doc.count_latin_words)
  end

  def test_ascii_count_latin_valid_words
    doc = Document.new("1 foo   \r\n%%% ()\r\n")
    expected = 2
    assert_equal(expected, doc.count_latin_valid_words)
  end

  def test_ascii_count_lines
    doc = Document.new("foo\r\nbar")
    expected = 2
    assert_equal(expected, doc.count_lines)
  end

  def test_ascii_count_graph_lines
    doc = Document.new("foo\r\n ")
    expected = 1
    assert_equal(expected, doc.count_graph_lines)
  end

  def test_ascii_count_empty_lines
    doc = Document.new("foo\r\n \r\n\t\r\n\r\n")
    expected = 1
    assert_equal(expected, doc.count_empty_lines)
  end

  def test_ascii_count_blank_lines
    doc = Document.new("\r\n \r\n\t\r\n ")
    expected = 3
    assert_equal(expected, doc.count_blank_lines)
  end

  # test EUCJP module
  def test_eucjp_split_to_words
    doc = Document.new(NKF.nkf("--euc", "日本語の文字foo bar"))
    expected = ["日本語の", "文字", "foo ", "bar"].map { |c| NKF.nkf("--euc", c) }
    assert_equal(expected, doc.split_to_words)
  end

  def test_eucjp_split_to_words_kanhira
    doc = Document.new(NKF.nkf("--euc", "日本語の文字"))
    expected = ["日本語の", "文字"].map { |c| NKF.nkf("--euc", c) }
    assert_equal(expected, doc.split_to_words)
  end

  def test_eucjp_split_to_words_katahira
    doc = Document.new(NKF.nkf("--euc", "カタカナの文字"))
    expected = ["カタカナの", "文字"].map { |c| NKF.nkf("--euc", c) }
    assert_equal(expected, doc.split_to_words)
  end

  def test_eucjp_split_to_words_kataonbiki
    doc = Document.new(NKF.nkf("--euc", "ルビー色の石"), "EUC-JP")
    expected = ["ルビー", "色の", "石"].map { |c| NKF.nkf("--euc", c) }
    assert_equal(expected, doc.split_to_words)
  end

  def test_eucjp_split_to_words_hiraonbiki
    doc = Document.new(NKF.nkf("--euc", "わールビーだ"), "EUC-JP")
    expected = ["わー", "ルビーだ"].map { |c| NKF.nkf("--euc", c) }
    assert_equal(expected, doc.split_to_words)
  end

  def test_eucjp_split_to_words_latinmix
    doc = Document.new(NKF.nkf("--euc", "日本語とLatinの文字"))
    expected = ["日本語と", "Latin", "の", "文字"].map { |c| NKF.nkf("--euc", c) }
    assert_equal(expected, doc.split_to_words)
  end

  def test_eucjp_split_to_chars
    doc = Document.new(NKF.nkf("--euc", "日本語a b"))
    expected = ["日", "本", "語", "a", " ", "b"].map { |c| NKF.nkf("--euc", c) }
    assert_equal(expected, doc.split_to_chars)
  end

  def test_eucjp_split_to_chars_with_cr
    doc = Document.new(NKF.nkf("--euc", "日本語a b\r"))
    expected = ["日", "本", "語", "a", " ", "b", "\r"].map { |c| NKF.nkf("--euc", c) }
    assert_equal(expected, doc.split_to_chars)
  end

  def test_eucjp_split_to_chars_with_lf
    doc = Document.new(NKF.nkf("--euc", "日本語a b\n"))
    expected = ["日", "本", "語", "a", " ", "b", "\n"].map { |c| NKF.nkf("--euc", c) }
    assert_equal(expected, doc.split_to_chars)
  end

  def test_eucjp_split_to_chars_with_crlf
    doc = Document.new(NKF.nkf("--euc", "日本語a b\r\n"))
    expected = ["日", "本", "語", "a", " ", "b", "\r\n"].map { |c| NKF.nkf("--euc", c) }
    assert_equal(expected, doc.split_to_chars)
  end

  def test_eucjp_count_chars
    doc = Document.new(NKF.nkf("--euc", "日本語a b\r\n"))
    expected = 7
    assert_equal(expected, doc.count_chars)
  end

  def test_eucjp_count_latin_graph_chars
    doc = Document.new(NKF.nkf("--euc", "日本語a b\r\n"))
    expected = 2
    assert_equal(expected, doc.count_latin_graph_chars)
  end

  def test_eucjp_count_ja_graph_chars
    doc = Document.new(NKF.nkf("--euc", "日本語a b\r\n"))
    expected = 3
    assert_equal(expected, doc.count_ja_graph_chars)
  end

  def test_eucjp_count_graph_chars
    doc = Document.new(NKF.nkf("--euc", "日本語a b\r\n"))
    expected = 5
    assert_equal(expected, doc.count_graph_chars)
  end

  def test_eucjp_count_latin_blank_chars
    doc = Document.new(NKF.nkf("--euc", "日本語\ta b\r\n"))
    expected = 2
    assert_equal(expected, doc.count_latin_blank_chars)
  end

  def test_eucjp_count_ja_blank_chars
    doc = Document.new(NKF.nkf("--euc", "日本　語\ta b\r\n"))
    expected = 1
    assert_equal(expected, doc.count_ja_blank_chars)
  end

  def test_eucjp_count_blank_chars
    doc = Document.new(NKF.nkf("--euc", "日本　語\ta b\r\n"))
    expected = 3
    assert_equal(expected, doc.count_blank_chars)
  end

  def test_eucjp_count_words
    doc = Document.new(NKF.nkf("--euc", "日本　語a b --\r\n"))
    expected = 7 # "--" and "\r\n" are counted as word here (though not "valid")
    assert_equal(expected, doc.count_words)
  end

  def test_eucjp_count_ja_words
    doc = Document.new(NKF.nkf("--euc", "日本　語a b --\r\n"))
    expected = 3
    assert_equal(expected, doc.count_ja_words)
  end

  def test_eucjp_count_latin_valid_words
    doc = Document.new(NKF.nkf("--euc", "日本　語a b --\r\n"))
    expected = 2
    assert_equal(expected, doc.count_latin_valid_words)
  end

  def test_eucjp_count_ja_valid_words
    doc = Document.new(NKF.nkf("--euc", "日本　語a b --\r\n"))
    expected = 2
    assert_equal(expected, doc.count_ja_valid_words)
  end

  def test_eucjp_count_valid_words
    doc = Document.new(NKF.nkf("--euc", "日本　語a b --\r\n"))
    expected = 4
    assert_equal(expected, doc.count_valid_words)
  end

  def test_eucjp_count_lines
    doc = Document.new(NKF.nkf("--euc", "日本語\r\n　\r\n \r\n\r\nfoo\r\nbar"))
    expected = 6
    assert_equal(expected, doc.count_lines)
  end

  def test_eucjp_count_graph_lines
    doc = Document.new(NKF.nkf("--euc", "日本語\r\n　\r\n \r\n\r\nfoo\r\nbar"))
    expected = 3
    assert_equal(expected, doc.count_graph_lines)
  end

  def test_eucjp_count_empty_lines
    doc = Document.new(NKF.nkf("--euc", "日本語\r\n　\r\n \r\n\r\nfoo\r\nbar"))
    expected = 1
    assert_equal(expected, doc.count_empty_lines)
  end

  def test_eucjp_count_blank_lines
    doc = Document.new(NKF.nkf("--euc", "日本語\r\n　\r\n \r\n\r\nfoo\r\nbar"))
    expected = 2
    assert_equal(expected, doc.count_blank_lines)
  end

  # test SJIS module
  def test_sjis_split_to_words
    doc = Document.new(NKF.nkf("--sjis", "日本語の文字foo bar"))
    expected = ["日本語の", "文字", "foo ", "bar"].map { |c| NKF.nkf("--sjis", c) }
    assert_equal(expected, doc.split_to_words)
  end

  def test_sjis_split_to_words_kanhira
    doc = Document.new(NKF.nkf("--sjis", "日本語の文字"))
    expected = ["日本語の", "文字"].map { |c| NKF.nkf("--sjis", c) }
    assert_equal(expected, doc.split_to_words)
  end

  def test_sjis_split_to_words_katahira
    doc = Document.new(NKF.nkf("--sjis", "カタカナの文字"))
    expected = ["カタカナの", "文字"].map { |c| NKF.nkf("--sjis", c) }
    assert_equal(expected, doc.split_to_words)
  end

  def test_sjis_split_to_words_kataonbiki
    doc = Document.new(NKF.nkf("--sjis", "ルビーの指輪"))
    expected = ["ルビーの", "指輪"].map { |c| NKF.nkf("--sjis", c) }
    assert_equal(expected, doc.split_to_words)
  end

  def test_sjis_split_to_words_hiraonbiki
    doc = Document.new(NKF.nkf("--sjis", "わールビーだ"))
    expected = ["わー", "ルビーだ"].map { |c| NKF.nkf("--sjis", c) }
    assert_equal(expected, doc.split_to_words)
  end

  def test_sjis_split_to_words_latinmix
    doc = Document.new(NKF.nkf("--sjis", "日本語とLatinの文字"))
    expected = ["日本語と", "Latin", "の", "文字"].map { |c| NKF.nkf("--sjis", c) }
    assert_equal(expected, doc.split_to_words)
  end

  def test_sjis_split_to_chars
    doc = Document.new(NKF.nkf("--sjis", "表計算a b"))
    expected = ["表", "計", "算", "a", " ", "b"].map { |c| NKF.nkf("--sjis", c) }
    assert_equal(expected, doc.split_to_chars)
  end

  def test_sjis_split_to_chars_with_cr
    doc = Document.new(NKF.nkf("--sjis", "表計算a b\r"))
    expected = ["表", "計", "算", "a", " ", "b", "\r"].map { |c| NKF.nkf("--sjis", c) }
    assert_equal(expected, doc.split_to_chars)
  end

  def test_sjis_split_to_chars_with_lf
    doc = Document.new(NKF.nkf("--sjis", "表計算a b\n"))
    expected = ["表", "計", "算", "a", " ", "b", "\n"].map { |c| NKF.nkf("--sjis", c) }
    assert_equal(expected, doc.split_to_chars)
  end

  def test_sjis_split_to_chars_with_crlf
    doc = Document.new(NKF.nkf("--sjis", "表計算a b\r\n"))
    expected = ["表", "計", "算", "a", " ", "b", "\r\n"].map { |c| NKF.nkf("--sjis", c) }
    assert_equal(expected, doc.split_to_chars)
  end

  def test_sjis_count_chars
    doc = Document.new(NKF.nkf("--sjis", "日本語a b\r\n"))
    expected = 7
    assert_equal(expected, doc.count_chars)
  end

  def test_sjis_count_latin_graph_chars
    doc = Document.new(NKF.nkf("--sjis", "日本語a b\r\n"))
    expected = 2
    assert_equal(expected, doc.count_latin_graph_chars)
  end

  def test_sjis_count_ja_graph_chars
    doc = Document.new(NKF.nkf("--sjis", "日本語a b\r\n"))
    expected = 3
    assert_equal(expected, doc.count_ja_graph_chars)
  end

  def test_sjis_count_graph_chars
    doc = Document.new(NKF.nkf("--sjis", "日本語a b\r\n"))
    expected = 5
    assert_equal(expected, doc.count_graph_chars)
  end

  def test_sjis_count_latin_blank_chars
    doc = Document.new(NKF.nkf("--sjis", "日本語\ta b\r\n"))
    expected = 2
    assert_equal(expected, doc.count_latin_blank_chars)
  end

  def test_sjis_count_ja_blank_chars
    doc = Document.new(NKF.nkf("--sjis", "日本　語\ta b\r\n"))
    expected = 1
    assert_equal(expected, doc.count_ja_blank_chars)
  end

  def test_sjis_count_blank_chars
    doc = Document.new(NKF.nkf("--sjis", "日本　語\ta b\r\n"))
    expected = 3
    assert_equal(expected, doc.count_blank_chars)
  end

  def test_sjis_count_words
    doc = Document.new(NKF.nkf("--sjis", "日本　語a b --\r\n"))
    expected = 7 # "--" and "\r\n" are counted as word here (though not "valid")
    assert_equal(expected, doc.count_words)
  end

  def test_sjis_count_ja_words
    doc = Document.new(NKF.nkf("--sjis", "日本　語a b --\r\n"))
    expected = 3
    assert_equal(expected, doc.count_ja_words)
  end

  def test_sjis_count_latin_valid_words
    doc = Document.new(NKF.nkf("--sjis", "日本　語a b --\r\n"))
    expected = 2
    assert_equal(expected, doc.count_latin_valid_words)
  end

  def test_sjis_count_ja_valid_words
    doc = Document.new(NKF.nkf("--sjis", "日本　語a b --\r\n"))
    expected = 2
    assert_equal(expected, doc.count_ja_valid_words)
  end

  def test_sjis_count_valid_words
    doc = Document.new(NKF.nkf("--sjis", "日本　語a b --\r\n"))
    expected = 4
    assert_equal(expected, doc.count_valid_words)
  end

  def test_sjis_count_lines
    doc = Document.new(NKF.nkf("--sjis", "日本語\r\n　\r\n \r\n\r\nfoo\r\nbar"))
    expected = 6
    assert_equal(expected, doc.count_lines)
  end

  def test_sjis_count_graph_lines
    doc = Document.new(NKF.nkf("--sjis", "日本語\r\n　\r\n \r\n\r\nfoo\r\nbar"))
    expected = 3
    assert_equal(expected, doc.count_graph_lines)
  end

  def test_sjis_count_empty_lines
    doc = Document.new(NKF.nkf("--sjis", "日本語\r\n　\r\n \r\n\r\nfoo\r\nbar"))
    expected = 1
    assert_equal(expected, doc.count_empty_lines)
  end

  def test_sjis_count_blank_lines
    doc = Document.new(NKF.nkf("--sjis", "日本語\r\n　\r\n \r\n\r\nfoo\r\nbar"))
    expected = 2
    assert_equal(expected, doc.count_blank_lines)
  end

  # test UTF8 module
  def test_utf8_split_to_words
    doc = Document.new(NKF.nkf("--utf8", "日本語の文字foo bar"))
    expected = ["日本語の", "文字", "foo ", "bar"].map { |c| NKF.nkf("--utf8", c) }
    assert_equal(expected, doc.split_to_words)
  end

  def test_utf8_split_to_words_kanhira
    doc = Document.new(NKF.nkf("--utf8", "日本語の文字"))
    expected = ["日本語の", "文字"].map { |c| NKF.nkf("--utf8", c) }
    assert_equal(expected, doc.split_to_words)
  end

  def test_utf8_split_to_words_katahira
    doc = Document.new(NKF.nkf("--utf8", "カタカナの文字"))
    expected = ["カタカナの", "文字"].map { |c| NKF.nkf("--utf8", c) }
    assert_equal(expected, doc.split_to_words)
  end

  def test_utf8_split_to_words_kataonbiki
    doc = Document.new(NKF.nkf("--utf8", "ルビーの指輪"))
    expected = ["ルビーの", "指輪"].map { |c| NKF.nkf("--utf8", c) }
    assert_equal(expected, doc.split_to_words)
  end

  def test_utf8_split_to_words_hiraonbiki
    doc = Document.new(NKF.nkf("--utf8", "わールビーだ"))
    expected = ["わー", "ルビーだ"].map { |c| NKF.nkf("--utf8", c) }
    assert_equal(expected, doc.split_to_words)
  end

  def test_utf8_split_to_words_latinmix
    doc = Document.new(NKF.nkf("--utf8", "日本語とLatinの文字"))
    expected = ["日本語と", "Latin", "の", "文字"].map { |c| NKF.nkf("--utf8", c) }
    assert_equal(expected, doc.split_to_words)
  end

  def test_utf8_split_to_chars
    doc = Document.new(NKF.nkf("--utf8", "日本語a b"), "UTF-8")
    expected = ["日", "本", "語", "a", " ", "b"].map { |c| NKF.nkf("--utf8", c) }
    assert_equal(expected, doc.split_to_chars)
  end

  def test_utf8_split_to_chars_with_cr
    doc = Document.new(NKF.nkf("--utf8", "日本語a b\r"), "UTF-8")
    expected = ["日", "本", "語", "a", " ", "b", "\r"].map { |c| NKF.nkf("--utf8", c) }
    assert_equal(expected, doc.split_to_chars)
  end

  def test_utf8_split_to_chars_with_lf
    doc = Document.new(NKF.nkf("--utf8", "日本語a b\n"), "UTF-8")
    expected = ["日", "本", "語", "a", " ", "b", "\n"].map { |c| NKF.nkf("--utf8", c) }
    assert_equal(expected, doc.split_to_chars)
  end

  def test_utf8_split_to_chars_with_crlf
    doc = Document.new(NKF.nkf("--utf8", "日本語a b\r\n"), "UTF-8")
    expected = ["日", "本", "語", "a", " ", "b", "\r\n"].map { |c| NKF.nkf("--utf8", c) }
    assert_equal(expected, doc.split_to_chars)
  end

  def test_utf8_count_chars
    doc = Document.new(NKF.nkf("--utf8", "日本語a b\r\n"), "UTF-8")
    expected = 7
    assert_equal(expected, doc.count_chars)
  end

  def test_utf8_count_latin_graph_chars
    doc = Document.new(NKF.nkf("--utf8", "日本語a b\r\n"), "UTF-8")
    expected = 2
    assert_equal(expected, doc.count_latin_graph_chars)
  end

  def test_utf8_count_ja_graph_chars
    doc = Document.new(NKF.nkf("--utf8", "日本語a b\r\n"), "UTF-8")
    expected = 3
    assert_equal(expected, doc.count_ja_graph_chars)
  end

  def test_utf8_count_graph_chars
    doc = Document.new(NKF.nkf("--utf8", "日本語a b\r\n"), "UTF-8")
    expected = 5
    assert_equal(expected, doc.count_graph_chars)
  end

  def test_utf8_count_latin_blank_chars
    doc = Document.new(NKF.nkf("--utf8", "日本語\ta b\r\n"))
    expected = 2
    assert_equal(expected, doc.count_latin_blank_chars)
  end

  def test_utf8_count_ja_blank_chars
    doc = Document.new(NKF.nkf("--utf8", "日本　語\ta b\r\n"))
    expected = 1
    assert_equal(expected, doc.count_ja_blank_chars)
  end

  def test_utf8_count_blank_chars
    doc = Document.new(NKF.nkf("--utf8", "日本　語\ta b\r\n"))
    expected = 3
    assert_equal(expected, doc.count_blank_chars)
  end

  def test_utf8_count_words
    doc = Document.new(NKF.nkf("--utf8", "日本　語a b --\r\n"))
    expected = 7 # "--" and "\r\n" are counted as word here (though not "valid")
    assert_equal(expected, doc.count_words)
  end

  def test_utf8_count_ja_words
    doc = Document.new(NKF.nkf("--utf8", "日本　語a b --\r\n"))
    expected = 3
    assert_equal(expected, doc.count_ja_words)
  end

  def test_utf8_count_latin_valid_words
    doc = Document.new(NKF.nkf("--utf8", "日本　語a b --\r\n"))
    expected = 2
    assert_equal(expected, doc.count_latin_valid_words)
  end

  def test_utf8_count_ja_valid_words
    doc = Document.new(NKF.nkf("--utf8", "日本　語a b --\r\n"))
    expected = 2
    assert_equal(expected, doc.count_ja_valid_words)
  end

  def test_utf8_count_valid_words
    doc = Document.new(NKF.nkf("--utf8", "日本　語a b --\r\n"))
    expected = 4
    assert_equal(expected, doc.count_valid_words)
  end

  def test_utf8_count_lines
    doc = Document.new(NKF.nkf("--utf8", "日本語\r\n　\r\n \r\n\r\nfoo\r\nbar"))
    expected = 6
    assert_equal(expected, doc.count_lines)
  end

  def test_utf8_count_graph_lines
    doc = Document.new(NKF.nkf("--utf8", "日本語\r\n　\r\n \r\n\r\nfoo\r\nbar"))
    expected = 3
    assert_equal(expected, doc.count_graph_lines)
  end

  def test_utf8_count_empty_lines
    doc = Document.new(NKF.nkf("--utf8", "日本語\r\n　\r\n \r\n\r\nfoo\r\nbar"))
    expected = 1
    assert_equal(expected, doc.count_empty_lines)
  end

  def test_utf8_count_blank_lines
    doc = Document.new(NKF.nkf("--utf8", "日本語\r\n　\r\n \r\n\r\nfoo\r\nbar"))
    expected = 2
    assert_equal(expected, doc.count_blank_lines)
  end

  def teardown
  end
end
