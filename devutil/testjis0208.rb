#!/usr/bin/env ruby
# frozen_string_literal: true

require "test/unit"
require_relative "jis0208"

class TestCaseJIS0208 < Test::Unit::TestCase
  # internal methods

  def test_utf16_to_utf8
    # "\xE3\x80\x80": U+3000 IDEOGRAPHIC SPACE in UTF-8
    expected = String.new("\xE3\x80\x80", encoding: Encoding::ASCII_8BIT)
    actual = JIS0208.new.utf16_to_utf8(["3000"].pack("H*"))
    assert_equal(expected, actual)
  end

  def test_characters
    expected = String.new("\xE3\x80\x80", encoding: Encoding::ASCII_8BIT)
    actual = JIS0208.new.characters[1][1][:u8]
    assert_equal(expected, actual)
  end

  def test_char
    expected = "\\xe3\\x80\\x80"
    actual = JIS0208.new.char(1, 1, "UTF-8")
    assert_equal(expected, actual)
  end

  # EUC-JP expressions

  def test_euc_ja_alnum
    exps = JIS0208.new.euc_ja_alnum
    expected = ["\\xa3\\xb0", "\\xa3\\xfa", 62]
    assert_equal(expected, [exps.first, exps.last, exps.size])
  end

  def test_euc_ja_blank
    exps = JIS0208.new.euc_ja_blank
    expected = ["\\xa1\\xa1", "\\xa1\\xa1", 1]
    assert_equal(expected, [exps.first, exps.last, exps.size])
  end

  def test_euc_ja_print
    exps = JIS0208.new.euc_ja_print
    expected = ["\\xa3\\xb0", "\\xa1\\xa1", 355]
    assert_equal(expected, [exps.first, exps.last, exps.size])
  end

  def test_euc_ja_graph
    exps = JIS0208.new.euc_ja_graph
    expected = ["\\xa3\\xb0", "\\xa8\\xc0", 354]
    assert_equal(expected, [exps.first, exps.last, exps.size])
  end

  def test_euc_ja_punct
    exps = JIS0208.new.euc_ja_punct
    expected = ["\\xa1\\xa2", "\\xa8\\xc0", 292]
    assert_equal(expected, [exps.first, exps.last, exps.size])
  end

  def test_euc_ja_space
    exps = JIS0208.new.euc_ja_space
    expected = ["\\xa1\\xa1", "\\xa1\\xa1", 1]
    assert_equal(expected, [exps.first, exps.last, exps.size])
  end

  def test_euc_hiragana
    exps = JIS0208.new.euc_hiragana
    expected = ["\\xa4\\xa1", "\\xa4\\xf3", 83]
    assert_equal(expected, [exps.first, exps.last, exps.size])
  end

  def test_euc_katakana
    exps = JIS0208.new.euc_katakana
    expected = ["\\xa5\\xa1", "\\xa5\\xf6", 86]
    assert_equal(expected, [exps.first, exps.last, exps.size])
  end

  def test_euc_kanji
    exps = JIS0208.new.euc_kanji
    expected = ["\\xb0\\xa1-\\xb0\\xfe", "\\xf4\\xa1-\\xf4\\xa6", 69]
    assert_equal(expected, [exps.first, exps.last, exps.size])
  end

  # Shift-JIS (CP932) expressions

  def test_sjis_ja_alnum
    exps = JIS0208.new.sjis_ja_alnum
    expected = ["\\x82\\x4f", "\\x82\\x9a", 62]
    assert_equal(expected, [exps.first, exps.last, exps.size])
  end

  def test_sjis_ja_blank
    exps = JIS0208.new.sjis_ja_blank
    expected = ["\\x81\\x40", "\\x81\\x40", 1]
    assert_equal(expected, [exps.first, exps.last, exps.size])
  end

  def test_sjis_ja_print
    exps = JIS0208.new.sjis_ja_print
    expected = ["\\x82\\x4f", "\\x81\\x40", 355]
    assert_equal(expected, [exps.first, exps.last, exps.size])
  end

  def test_sjis_ja_graph
    exps = JIS0208.new.sjis_ja_graph
    expected = ["\\x82\\x4f", "\\x84\\xbe", 354]
    assert_equal(expected, [exps.first, exps.last, exps.size])
  end

  def test_sjis_ja_punct
    exps = JIS0208.new.sjis_ja_punct
    expected = ["\\x81\\x41", "\\x84\\xbe", 292]
    assert_equal(expected, [exps.first, exps.last, exps.size])
  end

  def test_sjis_ja_space
    exps = JIS0208.new.sjis_ja_space
    expected = ["\\x81\\x40", "\\x81\\x40", 1]
    assert_equal(expected, [exps.first, exps.last, exps.size])
  end

  def test_sjis_hiragana
    exps = JIS0208.new.sjis_hiragana
    expected = ["\\x82\\x9f", "\\x82\\xf1", 83]
    assert_equal(expected, [exps.first, exps.last, exps.size])
  end

  def test_sjis_katakana
    exps = JIS0208.new.sjis_katakana
    expected = ["\\x83\\x40", "\\x83\\x96", 86]
    assert_equal(expected, [exps.first, exps.last, exps.size])
  end

  def test_sjis_kanji
    exps = JIS0208.new.sjis_kanji
    expected = ["\\x88\\x9f-\\x88\\xfc", "\\xea\\x9f-\\xea\\xa4", 69] # FIXME
    assert_equal(expected, [exps.first, exps.last, exps.size])
  end

  # UTF-8 expressions

  def test_utf8_ja_alnum
    exps = JIS0208.new.utf8_ja_alnum
    expected = ["\\xef\\xbc\\x90", "\\xef\\xbd\\x9a", 62]
    assert_equal(expected, [exps.first, exps.last, exps.size])
  end

  def test_utf8_ja_blank
    exps = JIS0208.new.utf8_ja_blank
    expected = ["\\xe3\\x80\\x80", "\\xe3\\x80\\x80", 1]
    assert_equal(expected, [exps.first, exps.last, exps.size])
  end

  def test_utf8_ja_print
    exps = JIS0208.new.utf8_ja_print
    expected = ["\\xef\\xbc\\x90", "\\xe3\\x80\\x80", 355]
    assert_equal(expected, [exps.first, exps.last, exps.size])
  end

  def test_utf8_ja_graph
    exps = JIS0208.new.utf8_ja_graph
    expected = ["\\xef\\xbc\\x90", "\\xe2\\x95\\x82", 354]
    assert_equal(expected, [exps.first, exps.last, exps.size])
  end

  def test_utf8_ja_punct
    exps = JIS0208.new.utf8_ja_punct
    expected = ["\\xe3\\x80\\x81", "\\xe2\\x95\\x82", 292]
    assert_equal(expected, [exps.first, exps.last, exps.size])
  end

  def test_utf8_ja_space
    exps = JIS0208.new.utf8_ja_space
    expected = ["\\xe3\\x80\\x80", "\\xe3\\x80\\x80", 1]
    assert_equal(expected, [exps.first, exps.last, exps.size])
  end

  def test_utf8_hiragana
    exps = JIS0208.new.utf8_hiragana
    expected = ["\\xe3\\x81\\x81", "\\xe3\\x82\\x93", 83]
    assert_equal(expected, [exps.first, exps.last, exps.size])
  end

  def test_utf8_katakana
    exps = JIS0208.new.utf8_katakana
    expected = ["\\xe3\\x82\\xa1", "\\xe3\\x83\\xb6", 86]
    assert_equal(expected, [exps.first, exps.last, exps.size])
  end

  def test_utf8_kanji
    exps = JIS0208.new.utf8_kanji
    expected = ["\\xe4\\xba\\x9c", "\\xe7\\x86\\x99", 6355]
    assert_equal(expected, [exps.first, exps.last, exps.size])
  end
end
