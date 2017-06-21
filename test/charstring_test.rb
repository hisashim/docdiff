#!/usr/bin/ruby
# -*- coding: euc-jp; -*-
require 'test/unit'
require 'docdiff/charstring'
require 'nkf'

class TC_DocDiff_CharString < Test::Unit::TestCase
  CharString = DocDiff::CharString

  def setup()
    #
  end

  # test encoding module registration
  def test_encoding_ascii()
    str = "foo".extend CharString
    str.encoding = "US-ASCII"
    expected = CharString::ASCII
    assert_equal(expected, CharString::Encodings[str.encoding])
  end
  def test_encoding_eucjp()
    str = "foo".extend CharString
    str.encoding = "EUC-JP"
    expected = CharString::EUC_JP
    assert_equal(expected, CharString::Encodings[str.encoding])
  end
  def test_encoding_sjis()
    str = "foo".extend CharString
    str.encoding = "Shift_JIS"
    expected = CharString::Shift_JIS
    assert_equal(expected, CharString::Encodings[str.encoding])
  end
  def test_encoding_utf8()
    str = "foo".extend CharString
    str.encoding = "UTF-8"
    expected = CharString::UTF8
    assert_equal(expected, CharString::Encodings[str.encoding])
  end

  # test eol module registration
  def test_eol_cr()
    str = "foo".extend CharString
    str.eol = "CR"
    expected = CharString::CR
    assert_equal(expected, CharString::EOLChars[str.eol])
  end
  def test_eol_lf()
    str = "foo".extend CharString
    str.eol = "LF"
    expected = CharString::LF
    assert_equal(expected, CharString::EOLChars[str.eol])
  end
  def test_eol_crlf()
    str = "foo".extend CharString
    str.eol = "CRLF"
    expected = CharString::CRLF
    assert_equal(expected, CharString::EOLChars[str.eol])
  end

  # test eol eol_char method
  def test_eol_char_cr()
    str = "foo\rbar\r".extend CharString
    str.eol = "CR"
    expected = "\r"
    assert_equal(expected, str.eol_char)
  end
  def test_eol_char_lf()
    str = "foo\nbar\n".extend CharString
    str.eol = "LF"
    expected = "\n"
    assert_equal(expected, str.eol_char)
  end
  def test_eol_char_crlf()
    str = "foo\r\nbar\r\n".extend CharString
    str.eol = "CRLF"
    expected = "\r\n"
    assert_equal(expected, str.eol_char)
  end
  def test_eol_char_none()
    str = "foobar".extend CharString
    expected = nil
    assert_equal(expected, str.eol_char)
  end
  def test_eol_char_none_for_0length_string()
    str = "".extend CharString
    expected = nil
    assert_equal(expected, str.eol_char)
  end
  def test_eol_char_none_eucjp()
    str = NKF.nkf("-e", "日本語a b").extend CharString
    expected = nil
    assert_equal(expected, str.eol_char)
  end
  def test_eol_char_none_sjis()
    str = NKF.nkf("-s", "日本語a b").extend CharString
    expected = nil
    assert_equal(expected, str.eol_char)
  end

  # test eol split_to_line() method
  def test_cr_split_to_line()
    str = "foo\rbar\r".extend CharString
    encoding, eol = "US-ASCII", "CR"
    str.encoding, str.eol = encoding, eol
    expected = ["foo\r", "bar\r"]
    assert_equal(expected, str.split_to_line)
  end
  def test_cr_split_to_line_chomped_lastline()
    str = "foo\rbar".extend CharString
    str.encoding = "US-ASCII"
    str.eol = "CR"
    expected = ["foo\r", "bar"]
    assert_equal(expected, str.split_to_line)
  end
  def test_cr_split_to_line_empty_line()
    str = "foo\r\rbar\r".extend CharString
    str.encoding = "US-ASCII"
    str.eol = "CR"
    expected = ["foo\r", "\r", "bar\r"]
    assert_equal(expected, str.split_to_line)
  end
  def test_lf_split_to_line()
    str = "foo\nbar\n".extend CharString
    str.encoding = "US-ASCII"
    str.eol = "LF"
    expected = ["foo\n", "bar\n"]
    assert_equal(expected, str.split_to_line)
  end
  def test_lf_split_to_line_chomped_lastline()
    str = "foo\nbar".extend CharString
    str.encoding = "US-ASCII"
    str.eol = "LF"
    expected = ["foo\n", "bar"]
    assert_equal(expected, str.split_to_line)
  end
  def test_lf_split_to_line_empty_line()
    str = "foo\n\nbar\n".extend CharString
    str.encoding = "US-ASCII"
    str.eol = "LF"
    expected = ["foo\n", "\n", "bar\n"]
    assert_equal(expected, str.split_to_line)
  end
  def test_crlf_split_to_line()
    str = "foo\r\nbar\r\n".extend CharString
    str.encoding = "US-ASCII"
    str.eol = "CRLF"
    expected = ["foo\r\n", "bar\r\n"]
    assert_equal(expected, str.split_to_line)
  end
  def test_crlf_split_to_line_chomped_lastline()
    str = "foo\r\nbar".extend CharString
    str.encoding = "US-ASCII"
    str.eol = "CRLF"
    expected = ["foo\r\n", "bar"]
    assert_equal(expected, str.split_to_line)
  end
  def test_crlf_split_to_line_empty_line()
    str = "foo\r\n\r\nbar\r\n".extend CharString
    str.encoding = "US-ASCII"
    str.eol = "CRLF"
    expected = ["foo\r\n", "\r\n", "bar\r\n"]
    assert_equal(expected, str.split_to_line)
  end

  # test ASCII module
  def test_ascii_split_to_word()
    str = "foo bar".extend CharString
    str.encoding = "US-ASCII"
    expected = ["foo ", "bar"]
    assert_equal(expected, str.split_to_word)
  end
  def test_ascii_split_to_word_withsymbol()
    str = "foo (bar) baz-baz".extend CharString
    str.encoding = "US-ASCII"
    expected = ["foo ", "(bar) ", "baz-baz"]
    assert_equal(expected, str.split_to_word)
  end
  def test_ascii_split_to_word_withquote()
    str = "foo's 'foo' \"bar\" 'baz.'".extend CharString
    str.encoding = "US-ASCII"
    expected = ["foo's ", "'foo' ", "\"bar\" ", "'baz.'"]
    assert_equal(expected, str.split_to_word)
  end
  def test_ascii_split_to_word_withlongspace()
    str = " foo  bar".extend CharString
    str.encoding = "US-ASCII"
    expected = [" ", "foo ", " ", "bar"]
    assert_equal(expected, str.split_to_word)
  end
  def test_ascii_split_to_word_withdash()
    str = "foo -- bar, baz - quux".extend CharString
    str.encoding = "US-ASCII"
    expected = ["foo ", "-- ", "bar, ", "baz ", "- ", "quux"]
    assert_equal(expected, str.split_to_word)
  end
  def test_ascii_split_to_char()
    str = "foo bar".extend CharString
    str.encoding = "US-ASCII"
    str.eol = "LF"
    expected = ["f","o","o"," ","b","a","r"]
    assert_equal(expected, str.split_to_char)
  end
  def test_ascii_split_to_char_with_eol_cr()
    str = "foo bar\r".extend CharString
    str.encoding = "US-ASCII"
    str.eol = "CR"
    expected = ["f","o","o"," ","b","a","r","\r"]
    assert_equal(expected, str.split_to_char)
  end
  def test_ascii_split_to_char_with_eol_lf()
    str = "foo bar\n".extend CharString
    str.encoding = "US-ASCII"
    str.eol = "LF"
    expected = ["f","o","o"," ","b","a","r","\n"]
    assert_equal(expected, str.split_to_char)
  end
  def test_ascii_split_to_char_with_eol_crlf()
    str = "foo bar\r\n".extend CharString
    str.encoding = "US-ASCII"
    str.eol = "CRLF"
    expected = ["f","o","o"," ","b","a","r","\r\n"]
    assert_equal(expected, str.split_to_char)
  end
  def test_ascii_split_to_byte()
    str = "foo bar\r\n".extend CharString
    str.encoding = "US-ASCII"
    str.eol = "CRLF"
    expected = ["f","o","o"," ","b","a","r","\r","\n"]
    assert_equal(expected, str.split_to_byte)
  end
  def test_ascii_count_byte()
    str = "foo bar\r\n".extend CharString
    str.encoding = "US-ASCII"
    str.eol = "CRLF"
    expected = 9
    assert_equal(expected, str.count_byte)
  end
  def test_ascii_count_char()
    str = "foo bar\r\nbaz quux\r\n".extend CharString
    str.encoding = "US-ASCII"
    str.eol = "CRLF"
    expected = 17
    assert_equal(expected, str.count_char)
  end
  def test_ascii_count_latin_graph_char()
    str = "foo bar\r\nbaz quux\r\n".extend CharString
    str.encoding = "US-ASCII"
    str.eol = "CRLF"
    expected = 13
    assert_equal(expected, str.count_latin_graph_char)
  end
  def test_ascii_count_graph_char()
    str = "foo bar\r\nbaz quux\r\n".extend CharString
    str.encoding = "US-ASCII"
    str.eol = "CRLF"
    expected = 13
    assert_equal(expected, str.count_graph_char)
  end
  def test_ascii_count_latin_blank_char()
    str = "foo bar\r\nbaz\tquux\r\n".extend CharString
    str.encoding = "US-ASCII"
    str.eol = "CRLF"
    expected = 2
    assert_equal(expected, str.count_latin_blank_char)
  end
  def test_ascii_count_blank_char()
    str = "foo bar\r\nbaz\tquux\r\n".extend CharString
    str.encoding = "US-ASCII"
    str.eol = "CRLF"
    expected = 2
    assert_equal(expected, str.count_blank_char)
  end
  def test_ascii_count_word()
    str = "foo bar   \r\nbaz quux\r\n".extend CharString
    str.encoding = "US-ASCII"
    str.eol = "CRLF"
    expected = 6
    assert_equal(expected, str.count_word)
  end
  def test_ascii_count_latin_word()
    str = "foo bar   \r\nbaz quux\r\n".extend CharString
    str.encoding = "US-ASCII"
    str.eol = "CRLF"
    expected = 5  # "  " is also counted as a word
    assert_equal(expected, str.count_latin_word)
  end
  def test_ascii_count_latin_valid_word()
    str = "1 foo   \r\n%%% ()\r\n".extend CharString
    str.encoding = "US-ASCII"
    str.eol = "CRLF"
    expected = 2
    assert_equal(expected, str.count_latin_valid_word)
  end
  def test_ascii_count_line()
    str = "foo\r\nbar".extend CharString
    str.encoding = "US-ASCII"
    str.eol = "CRLF"
    expected = 2
    assert_equal(expected, str.count_line)
  end
  def test_ascii_count_graph_line()
    str = "foo\r\n ".extend CharString
    str.encoding = "US-ASCII"
    str.eol = "CRLF"
    expected = 1
    assert_equal(expected, str.count_graph_line)
  end
  def test_ascii_count_empty_line()
    str = "foo\r\n \r\n\t\r\n\r\n".extend CharString
    str.encoding = "US-ASCII"
    str.eol = "CRLF"
    expected = 1
    assert_equal(expected, str.count_empty_line)
  end
  def test_ascii_count_blank_line()
    str = "\r\n \r\n\t\r\n ".extend CharString
    str.encoding = "US-ASCII"
    str.eol = "CRLF"
    expected = 3
    assert_equal(expected, str.count_blank_line)
  end

  # test EUCJP module
  def test_eucjp_split_to_word()
    str = NKF.nkf("-e", "日本語の文字foo bar").extend CharString
    str.encoding = "EUC-JP"
    expected = ["日本語の","文字","foo ","bar"].collect{|c| NKF.nkf("-e", c)}
    assert_equal(expected, str.split_to_word)
  end
  def test_eucjp_split_to_word_kanhira()
    str = NKF.nkf("-e", "日本語の文字").extend CharString
    str.encoding = "EUC-JP"
    expected = ["日本語の", "文字"].collect{|c| NKF.nkf("-e", c)}
    assert_equal(expected, str.split_to_word)
  end
  def test_eucjp_split_to_word_katahira()
    str = NKF.nkf("-e", "カタカナの文字").extend CharString
    str.encoding = "EUC-JP"
    expected = ["カタカナの", "文字"].collect{|c| NKF.nkf("-e", c)}
    assert_equal(expected, str.split_to_word)
  end
  def test_eucjp_split_to_word_kataonbiki()
    str = NKF.nkf("-e", "ルビー色の石").extend CharString
    str.encoding = "EUC-JP" #<= needed to pass the test
    expected = ["ルビー", "色の", "石"].collect{|c| NKF.nkf("-e", c)}
    assert_equal(expected, str.split_to_word)
  end
  def test_eucjp_split_to_word_hiraonbiki()
    str = NKF.nkf("-e", "わールビーだ").extend CharString
    str.encoding = "EUC-JP" #<= needed to pass the test
    expected = ["わー", "ルビーだ"].collect{|c| NKF.nkf("-e", c)}
    assert_equal(expected, str.split_to_word)
  end
  def test_eucjp_split_to_word_latinmix()
    str = NKF.nkf("-e", "日本語とLatinの文字").extend CharString
    str.encoding = "EUC-JP"
    expected = ["日本語と", "Latin", "の", "文字"].collect{|c| NKF.nkf("-e", c)}
    assert_equal(expected, str.split_to_word)
  end
  def test_eucjp_split_to_char()
    str = NKF.nkf("-e", "日本語a b").extend CharString
    str.encoding = "EUC-JP"
    str.eol = "LF" #<= needed to pass the test
    expected = ["日","本","語","a"," ","b"].collect{|c|NKF.nkf("-e",c)}
    assert_equal(expected, str.split_to_char)
  end
  def test_eucjp_split_to_char_with_cr()
    str = NKF.nkf("-e", "日本語a b\r").extend CharString
    str.encoding = "EUC-JP"
    str.eol = "CR"
    expected = ["日","本","語","a"," ","b","\r"].collect{|c|NKF.nkf("-e",c)}
    assert_equal(expected, str.split_to_char)
  end
  def test_eucjp_split_to_char_with_lf()
    str = NKF.nkf("-e", "日本語a b\n").extend CharString
    str.encoding = "EUC-JP"
    str.eol = "LF"
    expected = ["日","本","語","a"," ","b","\n"].collect{|c|NKF.nkf("-e",c)}
    assert_equal(expected, str.split_to_char)
  end
  def test_eucjp_split_to_char_with_crlf()
    str = NKF.nkf("-e", "日本語a b\r\n").extend CharString
    str.encoding = "EUC-JP"
    str.eol = "CRLF"
    expected = ["日","本","語","a"," ","b","\r\n"].collect{|c|NKF.nkf("-e",c)}
    assert_equal(expected, str.split_to_char)
  end
  def test_eucjp_count_char()
    str = NKF.nkf("-e", "日本語a b\r\n").extend CharString
    str.encoding = "EUC-JP"
    str.eol = "CRLF"
    expected = 7
    assert_equal(expected, str.count_char)
  end
  def test_eucjp_count_latin_graph_char()
    str = NKF.nkf("-e", "日本語a b\r\n").extend CharString
    str.encoding = "EUC-JP"
    str.eol = "CRLF"
    expected = 2
    assert_equal(expected, str.count_latin_graph_char)
  end
  def test_eucjp_count_ja_graph_char()
    str = NKF.nkf("-e", "日本語a b\r\n").extend CharString
    str.encoding = "EUC-JP"
    str.eol = "CRLF"
    expected = 3
    assert_equal(expected, str.count_ja_graph_char)
  end
  def test_eucjp_count_graph_char()
    str = NKF.nkf("-e", "日本語a b\r\n").extend CharString
    str.encoding = "EUC-JP"
    str.eol = "CRLF"
    expected = 5
    assert_equal(expected, str.count_graph_char)
  end
  def test_eucjp_count_latin_blank_char()
    str = NKF.nkf("-e", "日本語\ta b\r\n").extend CharString
    str.encoding = "EUC-JP"
    str.eol = "CRLF"
    expected = 2
    assert_equal(expected, str.count_latin_blank_char)
  end
  def test_eucjp_count_ja_blank_char()
    str = NKF.nkf("-e", "日本　語\ta b\r\n").extend CharString
    str.encoding = "EUC-JP"
    str.eol = "CRLF"
    expected = 1
    assert_equal(expected, str.count_ja_blank_char)
  end
  def test_eucjp_count_blank_char()
    str = NKF.nkf("-e", "日本　語\ta b\r\n").extend CharString
    str.encoding = "EUC-JP"
    str.eol = "CRLF"
    expected = 3
    assert_equal(expected, str.count_blank_char)
  end
  def test_eucjp_count_word()
    str = NKF.nkf("-e", "日本　語a b --\r\n").extend CharString
    str.encoding = "EUC-JP"
    str.eol = "CRLF"
    expected = 7 # "--" and "\r\n" are counted as word here (though not "valid")
    assert_equal(expected, str.count_word)
  end
  def test_eucjp_count_ja_word()
    str = NKF.nkf("-e", "日本　語a b --\r\n").extend CharString
    str.encoding = "EUC-JP"
    str.eol = "CRLF"
    expected = 3
    assert_equal(expected, str.count_ja_word)
  end
  def test_eucjp_count_latin_valid_word()
    str = NKF.nkf("-e", "日本　語a b --\r\n").extend CharString
    str.encoding = "EUC-JP"
    str.eol = "CRLF"
    expected = 2
    assert_equal(expected, str.count_latin_valid_word)
  end
  def test_eucjp_count_ja_valid_word()
    str = NKF.nkf("-e", "日本　語a b --\r\n").extend CharString
    str.encoding = "EUC-JP"
    str.eol = "CRLF"
    expected = 2
    assert_equal(expected, str.count_ja_valid_word)
  end
  def test_eucjp_count_valid_word()
    str = NKF.nkf("-e", "日本　語a b --\r\n").extend CharString
    str.encoding = "EUC-JP"
    str.eol = "CRLF"
    expected = 4
    assert_equal(expected, str.count_valid_word)
  end
  def test_eucjp_count_line()
    str = NKF.nkf("-e", "日本語\r\n　\r\n \r\n\r\nfoo\r\nbar").extend CharString
    str.encoding = "EUC-JP"
    str.eol = "CRLF"
    expected = 6
    assert_equal(expected, str.count_line)
  end
  def test_eucjp_count_graph_line()
    str = NKF.nkf("-e", "日本語\r\n　\r\n \r\n\r\nfoo\r\nbar").extend CharString
    str.encoding = "EUC-JP"
    str.eol = "CRLF"
    expected = 3
    assert_equal(expected, str.count_graph_line)
  end
  def test_eucjp_count_empty_line()
    str = NKF.nkf("-e", "日本語\r\n　\r\n \r\n\r\nfoo\r\nbar").extend CharString
    str.encoding = "EUC-JP"
    str.eol = "CRLF"
    expected = 1
    assert_equal(expected, str.count_empty_line)
  end
  def test_eucjp_count_blank_line()
    str = NKF.nkf("-e", "日本語\r\n　\r\n \r\n\r\nfoo\r\nbar").extend CharString
    str.encoding = "EUC-JP"
    str.eol = "CRLF"
    expected = 2
    assert_equal(expected, str.count_blank_line)
  end

  # test SJIS module
  def test_sjis_split_to_word()
    str = NKF.nkf("-s", "日本語の文字foo bar").extend CharString
    str.encoding = "Shift_JIS"
    expected = ["日本語の", "文字", "foo ", "bar"].collect{|c|NKF.nkf("-s",c)}
    assert_equal(expected, str.split_to_word)
  end
  def test_sjisplit_s_to_word_kanhira()
    str = NKF.nkf("-s", "日本語の文字").extend CharString
    str.encoding = "Shift_JIS"
    expected = ["日本語の", "文字"].collect{|c| NKF.nkf("-s", c)}
    assert_equal(expected, str.split_to_word)
  end
  def test_sjis_split_to_word_katahira()
    str = NKF.nkf("-s", "カタカナの文字").extend CharString
    str.encoding = "Shift_JIS"
    expected = ["カタカナの", "文字"].collect{|c| NKF.nkf("-s", c)}
    assert_equal(expected, str.split_to_word)
  end
  def test_sjis_split_to_word_kataonbiki()
    str = NKF.nkf("-s", "ルビーの指輪").extend CharString
    str.encoding = "Shift_JIS"
    expected = ["ルビーの", "指輪"].collect{|c| NKF.nkf("-s", c)}
    assert_equal(expected, str.split_to_word)
  end
  def test_sjis_split_to_word_hiraonbiki()
    str = NKF.nkf("-s", "わールビーだ").extend CharString
    str.encoding = "Shift_JIS"
    expected = ["わー", "ルビーだ"].collect{|c| NKF.nkf("-s", c)}
    assert_equal(expected, str.split_to_word)
  end
  def test_sjis_split_to_word_latinmix()
    str = NKF.nkf("-s", "日本語とLatinの文字").extend CharString
    str.encoding = "Shift_JIS"
    expected = ["日本語と","Latin","の","文字"].collect{|c| NKF.nkf("-s", c)}
    assert_equal(expected, str.split_to_word)
  end
  def test_sjis_split_to_char()
    str = NKF.nkf("-s", "表計算a b").extend CharString
    str.encoding = "Shift_JIS"
    str.eol = "LF" #<= needed to pass the test
    expected = ["表","計","算","a"," ","b"].collect{|c|NKF.nkf("-s",c)}
    assert_equal(expected, str.split_to_char)
  end
  def test_sjis_split_to_char_with_cr()
    str = NKF.nkf("-s", "表計算a b\r").extend CharString
    str.encoding = "Shift_JIS"
    str.eol = "CR"
    expected = ["表","計","算","a"," ","b","\r"].collect{|c|NKF.nkf("-s",c)}
    assert_equal(expected, str.split_to_char)
  end
  def test_sjis_split_to_char_with_lf()
    str = NKF.nkf("-s", "表計算a b\n").extend CharString
    str.encoding = "Shift_JIS"
    str.eol = "LF"
    expected = ["表","計","算","a"," ","b","\n"].collect{|c|NKF.nkf("-s",c)}
    assert_equal(expected, str.split_to_char)
  end
  def test_sjis_split_to_char_with_crlf()
    str = NKF.nkf("-s", "表計算a b\r\n").extend CharString
    str.encoding = "Shift_JIS"
    str.eol = "CRLF"
    expected = ["表","計","算","a"," ","b","\r\n"].collect{|c|NKF.nkf("-s",c)}
    assert_equal(expected, str.split_to_char)
  end
  def test_sjis_count_char()
    str = NKF.nkf("-s", "日本語a b\r\n").extend CharString
    str.encoding = "Shift_JIS"
    str.eol = "CRLF"
    expected = 7
    assert_equal(expected, str.count_char)
  end
  def test_sjis_count_latin_graph_char()
    str = NKF.nkf("-s", "日本語a b\r\n").extend CharString
    str.encoding = "Shift_JIS"
    str.eol = "CRLF"
    expected = 2
    assert_equal(expected, str.count_latin_graph_char)
  end
  def test_sjis_count_ja_graph_char()
    str = NKF.nkf("-s", "日本語a b\r\n").extend CharString
    str.encoding = "Shift_JIS"
    str.eol = "CRLF"
    expected = 3
    assert_equal(expected, str.count_ja_graph_char)
  end
  def test_sjis_count_graph_char()
    str = NKF.nkf("-s", "日本語a b\r\n").extend CharString
    str.encoding = "Shift_JIS"
    str.eol = "CRLF"
    expected = 5
    assert_equal(expected, str.count_graph_char)
  end
  def test_sjis_count_latin_blank_char()
    str = NKF.nkf("-s", "日本語\ta b\r\n").extend CharString
    str.encoding = "Shift_JIS"
    str.eol = "CRLF"
    expected = 2
    assert_equal(expected, str.count_latin_blank_char)
  end
  def test_sjis_count_ja_blank_char()
    str = NKF.nkf("-s", "日本　語\ta b\r\n").extend CharString
    str.encoding = "Shift_JIS"
    str.eol = "CRLF"
    expected = 1
    assert_equal(expected, str.count_ja_blank_char)
  end
  def test_sjis_count_blank_char()
    str = NKF.nkf("-s", "日本　語\ta b\r\n").extend CharString
    str.encoding = "Shift_JIS"
    str.eol = "CRLF"
    expected = 3
    assert_equal(expected, str.count_blank_char)
  end
  def test_sjis_count_word()
    str = NKF.nkf("-s", "日本　語a b --\r\n").extend CharString
    str.encoding = "Shift_JIS"
    str.eol = "CRLF"
    expected = 7 # "--" and "\r\n" are counted as word here (though not "valid")
    assert_equal(expected, str.count_word)
  end
  def test_sjis_count_ja_word()
    str = NKF.nkf("-s", "日本　語a b --\r\n").extend CharString
    str.encoding = "Shift_JIS"
    str.eol = "CRLF"
    expected = 3
    assert_equal(expected, str.count_ja_word)
  end
  def test_sjis_count_latin_valid_word()
    str = NKF.nkf("-s", "日本　語a b --\r\n").extend CharString
    str.encoding = "Shift_JIS"
    str.eol = "CRLF"
    expected = 2
    assert_equal(expected, str.count_latin_valid_word)
  end
  def test_sjis_count_ja_valid_word()
    str = NKF.nkf("-s", "日本　語a b --\r\n").extend CharString
    str.encoding = "Shift_JIS"
    str.eol = "CRLF"
    expected = 2
    assert_equal(expected, str.count_ja_valid_word)
  end
  def test_sjis_count_valid_word()
    str = NKF.nkf("-s", "日本　語a b --\r\n").extend CharString
    str.encoding = "Shift_JIS"
    str.eol = "CRLF"
    expected = 4
    assert_equal(expected, str.count_valid_word)
  end
  def test_sjis_count_line()
    str = NKF.nkf("-s", "日本語\r\n　\r\n \r\n\r\nfoo\r\nbar").extend CharString
    str.encoding = "Shift_JIS"
    str.eol = "CRLF"
    expected = 6
    assert_equal(expected, str.count_line)
  end
  def test_sjis_count_graph_line()
    str = NKF.nkf("-s", "日本語\r\n　\r\n \r\n\r\nfoo\r\nbar").extend CharString
    str.encoding = "Shift_JIS"
    str.eol = "CRLF"
    expected = 3
    assert_equal(expected, str.count_graph_line)
  end
  def test_sjis_count_empty_line()
    str = NKF.nkf("-s", "日本語\r\n　\r\n \r\n\r\nfoo\r\nbar").extend CharString
    str.encoding = "Shift_JIS"
    str.eol = "CRLF"
    expected = 1
    assert_equal(expected, str.count_empty_line)
  end
  def test_sjis_count_blank_line()
    str = NKF.nkf("-s", "日本語\r\n　\r\n \r\n\r\nfoo\r\nbar").extend CharString
    str.encoding = "Shift_JIS"
    str.eol = "CRLF"
    expected = 2
    assert_equal(expected, str.count_blank_line)
  end

  # test UTF8 module
  def test_utf8_split_to_word()
    str = NKF.nkf("-E -w", "日本語の文字foo bar").extend CharString
    str.encoding = "UTF-8"
    expected = ["日本語の", "文字", "foo ", "bar"].collect{|c| NKF.nkf("-E -w", c)}
    assert_equal(expected, str.split_to_word)
  end
  def test_utf8_split_to_word_kanhira()
    str = NKF.nkf("-E -w", "日本語の文字").extend CharString
    str.encoding = "UTF-8"
    expected = ["日本語の", "文字"].collect{|c| NKF.nkf("-E -w", c)}
    assert_equal(expected, str.split_to_word)
  end
  def test_utf8_split_to_word_katahira()
    str = NKF.nkf("-E -w", "カタカナの文字").extend CharString
    str.encoding = "UTF-8"
    expected = ["カタカナの", "文字"].collect{|c| NKF.nkf("-E -w", c)}
    assert_equal(expected, str.split_to_word)
  end
  def test_utf8_split_to_word_kataonbiki()
    str = NKF.nkf("-E -w", "ルビーの指輪").extend CharString
    str.encoding = "UTF-8"
    expected = ["ルビーの", "指輪"].collect{|c| NKF.nkf("-E -w", c)}
    assert_equal(expected, str.split_to_word)
  end
  def test_utf8_split_to_word_hiraonbiki()
    str = NKF.nkf("-E -w", "わールビーだ").extend CharString
    str.encoding = "UTF-8"
    expected = ["わー", "ルビーだ"].collect{|c| NKF.nkf("-E -w", c)}
    assert_equal(expected, str.split_to_word)
  end
  def test_utf8_split_to_word_latinmix()
    str = NKF.nkf("-E -w", "日本語とLatinの文字").extend CharString
    str.encoding = "UTF-8"
    expected = ["日本語と", "Latin", "の", "文字"].collect{|c| NKF.nkf("-E -w", c)}
    assert_equal(expected, str.split_to_word)
  end
  def test_utf8_split_to_char()
    str = NKF.nkf("-E -w", "日本語a b").extend CharString
    str.encoding = "UTF-8" #<= needed to pass the test
    str.eol = "LF"        #<= needed to pass the test
    expected = ["日", "本", "語", "a", " ", "b"].collect{|c| NKF.nkf("-E -w", c)}
    assert_equal(expected, str.split_to_char)
  end
  def test_utf8_split_to_char_with_cr()
    str = NKF.nkf("-E -w", "日本語a b\r").extend CharString
    str.encoding = "UTF-8" #<= needed to pass the test
    str.eol = "CR"
    expected = ["日","本","語","a"," ","b","\r"].collect{|c| NKF.nkf("-E -w", c)}
    assert_equal(expected, str.split_to_char)
  end
  def test_utf8_split_to_char_with_lf()
    str = NKF.nkf("-E -w", "日本語a b\n").extend CharString
    str.encoding = "UTF-8" #<= needed to pass the test
    str.eol = "LF"
    expected = ["日","本","語","a"," ","b","\n"].collect{|c| NKF.nkf("-E -w", c)}
    assert_equal(expected, str.split_to_char)
  end
  def test_utf8_split_to_char_with_crlf()
    str = NKF.nkf("-E -w", "日本語a b\r\n").extend CharString
    str.encoding = "UTF-8"#<= needed to pass the test
    str.eol = "CRLF"
    expected = ["日","本","語","a"," ","b","\r\n"].collect{|c| NKF.nkf("-E -w", c)}
    assert_equal(expected, str.split_to_char)
  end
  def test_utf8_count_char()
    str = NKF.nkf("-E -w", "日本語a b\r\n").extend CharString
    str.encoding = "UTF-8" #<= needed to pass the test
    str.eol = "CRLF"
    expected = 7
    assert_equal(expected, str.count_char)
  end
  def test_utf8_count_latin_graph_char()
    str = NKF.nkf("-E -w", "日本語a b\r\n").extend CharString
    str.encoding = "UTF-8" #<= needed to pass the test
    str.eol = "CRLF"
    expected = 2
    assert_equal(expected, str.count_latin_graph_char)
  end
  def test_utf8_count_ja_graph_char()
    str = NKF.nkf("-E -w", "日本語a b\r\n").extend CharString
    str.encoding = "UTF-8" #<= needed to pass the test
    str.eol = "CRLF"
    expected = 3
    assert_equal(expected, str.count_ja_graph_char)
  end
  def test_utf8_count_graph_char()
    str = NKF.nkf("-E -w", "日本語a b\r\n").extend CharString
    str.encoding = "UTF-8" #<= needed to passs the test
    str.eol = "CRLF"
    expected = 5
    assert_equal(expected, str.count_graph_char)
  end
  def test_utf8_count_latin_blank_char()
    str = NKF.nkf("-E -w", "日本語\ta b\r\n").extend CharString
    str.encoding = "UTF-8"
    str.eol = "CRLF"
    expected = 2
    assert_equal(expected, str.count_latin_blank_char)
  end
  def test_utf8_count_ja_blank_char()
    str = NKF.nkf("-E -w", "日本　語\ta b\r\n").extend CharString
    str.encoding = "UTF-8"
    str.eol = "CRLF"
    expected = 1
    assert_equal(expected, str.count_ja_blank_char)
  end
  def test_utf8_count_blank_char()
    str = NKF.nkf("-E -w", "日本　語\ta b\r\n").extend CharString
    str.encoding = "UTF-8"
    str.eol = "CRLF"
    expected = 3
    assert_equal(expected, str.count_blank_char)
  end
  def test_utf8_count_word()
    str = NKF.nkf("-E -w", "日本　語a b --\r\n").extend CharString
    str.encoding = "UTF-8"
    str.eol = "CRLF"
    expected = 7 # "--" and "\r\n" are counted as word here (though not "valid")
    assert_equal(expected, str.count_word)
  end
  def test_utf8_count_ja_word()
    str = NKF.nkf("-E -w", "日本　語a b --\r\n").extend CharString
    str.encoding = "UTF-8"
    str.eol = "CRLF"
    expected = 3
    assert_equal(expected, str.count_ja_word)
  end
  def test_utf8_count_latin_valid_word()
    str = NKF.nkf("-E -w", "日本　語a b --\r\n").extend CharString
    str.encoding = "UTF-8"
    str.eol = "CRLF"
    expected = 2
    assert_equal(expected, str.count_latin_valid_word)
  end
  def test_utf8_count_ja_valid_word()
    str = NKF.nkf("-E -w", "日本　語a b --\r\n").extend CharString
    str.encoding = "UTF-8"
    str.eol = "CRLF"
    expected = 2
    assert_equal(expected, str.count_ja_valid_word)
  end
  def test_utf8_count_valid_word()
    str = NKF.nkf("-E -w", "日本　語a b --\r\n").extend CharString
    str.encoding = "UTF-8"
    str.eol = "CRLF"
    expected = 4
    assert_equal(expected, str.count_valid_word)
  end
  def test_utf8_count_line()
    str = NKF.nkf("-E -w", "日本語\r\n　\r\n \r\n\r\nfoo\r\nbar").extend CharString
    str.encoding = "UTF-8"
    str.eol = "CRLF"
    expected = 6
    assert_equal(expected, str.count_line)
  end
  def test_utf8_count_graph_line()
    str = NKF.nkf("-E -w", "日本語\r\n　\r\n \r\n\r\nfoo\r\nbar").extend CharString
    str.encoding = "UTF-8"
    str.eol = "CRLF"
    expected = 3
    assert_equal(expected, str.count_graph_line)
  end
  def test_utf8_count_empty_line()
    str = NKF.nkf("-E -w", "日本語\r\n　\r\n \r\n\r\nfoo\r\nbar").extend CharString
    str.encoding = "UTF-8"
    str.eol = "CRLF"
    expected = 1
    assert_equal(expected, str.count_empty_line)
  end
  def test_utf8_count_blank_line()
    str = NKF.nkf("-E -w", "日本語\r\n　\r\n \r\n\r\nfoo\r\nbar").extend CharString
    str.encoding = "UTF-8"
    str.eol = "CRLF"
    expected = 2
    assert_equal(expected, str.count_blank_line)
  end

  # test module functions

  def assert_guess_encoding(expected, str)
    assert_equal(expected, CharString.guess_encoding(str))
  end

  def test_guess_encoding_nil()
    str = nil
    expected = nil
    assert_guess_encoding(expected, str)
  end
#   def test_guess_encoding_binary()
#     str = "\xFF\xFF"
#     expected = "BINARY"
#     assert_equal(expected, CharString.guess_encoding(str))
#   end
  def test_guess_encoding_unknown()
    str = "".encode("BINARY") # cannot put invalid string literal
    expected = "ASCII-8BIT"
    assert_guess_encoding(expected, str)
  end
  def test_guess_encoding_ascii_1()
    str = "ASCII string".encode("US-ASCII")
    expected = "US-ASCII"
    assert_guess_encoding(expected, str)
  end
  def test_guess_encoding_ascii_2()
    str = "abc\ndef\n".encode("US-ASCII")
    expected = "US-ASCII"
    assert_guess_encoding(expected, str)
  end
# CharString.guess_encoding mistakes JIS for ASCII sometimes, due to Iconv.
#   def test_guess_encoding_jis_1()
#     str = NKF.nkf("-j", "漢字とカタカナとひらがな\n")
#     expected = "JIS"
#     assert_guess_encoding(expected, str)
#   end
#   def test_guess_encoding_jis_2()
#     str = NKF.nkf("-j", "漢字とカタカナとひらがなとLatinの文字と空白( )と記号@\n" * 100)
#     expected = "JIS"
#     assert_guess_encoding(expected, str)
#   end
  def test_guess_encoding_eucjp_1()
    str = NKF.nkf("-e", "日本語とLatinの文字")
    expected = "EUC-JP"
    assert_guess_encoding(expected, str)
  end
  def test_guess_encoding_eucjp_2()
    str = NKF.nkf('-e', "漢字とカタカナとひらがなとLatinの文字と空白( )\n" * 10)
    expected = "EUC-JP"
    assert_guess_encoding(expected, str)
  end
  def test_guess_encoding_eucjp_3()
    str = NKF.nkf('-e', "こんばんは、私の名前はまつもとです。\nRubyを作ったのは私です。私はRuby Hackerです。\n")
    expected = "EUC-JP"
    assert_guess_encoding(expected, str)
  end
  def test_guess_encoding_sjis_1()
    str = NKF.nkf("-s", "日本語とLatinの文字")
    expected = "Shift_JIS"
    assert_guess_encoding(expected, str)
  end
  def test_guess_encoding_sjis_2()
    str = NKF.nkf('-s', "漢字と\nカタカナと\nひらがなと\nLatin")
    expected = "Shift_JIS"
    assert_guess_encoding(expected, str)
  end
  def test_guess_encoding_cp932_1()
    str = NKF.nkf('--oc=CP932', "\\u2460") # CIRCLED DIGIT ONE
    expected = "Windows-31J" # CP932 == Windows-31J in Ruby 1.9+
    assert_guess_encoding(expected, str)
  end
  def test_guess_encoding_utf8_1()
    str = NKF.nkf("-E -w", "日本語とLatinの文字")
    expected = "UTF-8"
    assert_guess_encoding(expected, str)
  end
  def test_guess_encoding_utf8_2()
    str = NKF.nkf("-E -w", "いろは\nにほへと\n")
    expected = "UTF-8"
    assert_guess_encoding(expected, str)
  end

  def test_guess_eol_nil()
    str = nil
    expected = nil
    assert_equal(expected, CharString.guess_eol(str))
  end
  def test_guess_eol_empty()
    str = ""
    expected = "NONE"
    assert_equal(expected, CharString.guess_eol(str))
  end
  def test_guess_eol_none()
    str = "foo bar"
    expected = "NONE"
    assert_equal(expected, CharString.guess_eol(str))
  end
  def test_guess_eol_cr()
    str = "foo bar\r"
    expected = "CR"
    assert_equal(expected, CharString.guess_eol(str))
  end
  def test_guess_eol_lf()
    str = "foo bar\n"
    expected = "LF"
    assert_equal(expected, CharString.guess_eol(str))
  end
  def test_guess_eol_crlf()
    str = "foo bar\r\n"
    expected = "CRLF"
    assert_equal(expected, CharString.guess_eol(str))
  end
  def test_guess_eol_mixed()
    str = "foo\rbar\nbaz\r\n"
    expected = "UNKNOWN"
    assert_equal(expected, CharString.guess_eol(str))
  end
  def test_guess_eol_cr2()
    str = "foo\rbar\rbaz\r".extend CharString
    expected = "CR"
    assert_equal(expected, CharString.guess_eol(str))
  end
  def test_guess_eol_lf2()
    str = "foo\nbar\nbaz\n".extend CharString
    expected = "LF"
    assert_equal(expected, CharString.guess_eol(str))
  end
  def test_guess_eol_crlf2()
    str = "foo\r\nbar\r\nbaz\r\n".extend CharString
    expected = "CRLF"
    assert_equal(expected, CharString.guess_eol(str))
  end

  def teardown()
    #
  end

end
