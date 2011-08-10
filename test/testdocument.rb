#!/usr/bin/ruby
# -*- coding: euc-jp; -*-
require 'test/unit'
require 'docdiff/document'
require 'nkf'

class TC_Document < Test::Unit::TestCase

  def setup()
    #
  end

  def test_encoding()
    doc = Document.new("Foo bar.\nBaz quux.")
    doc.encoding = 'US-ASCII'
    doc.eol = 'LF'
    expected = 'US-ASCII'
    assert_equal(expected, doc.encoding)
  end
  def test_encoding_auto()
    doc = if CharString.ruby_m17n?
            Document.new("Foo bar.\nBaz quux.".encode("US-ASCII"))
          else
            Document.new("Foo bar.\nBaz quux.")
          end
    expected = 'US-ASCII'
    assert_equal(expected, doc.encoding)
  end
  def test_eol()
    doc = Document.new("Foo bar.\nBaz quux.")
    doc.encoding = 'US-ASCII'
    doc.eol = 'LF'
    expected = 'LF'
    assert_equal(expected, doc.eol)
  end
  def test_eol_auto_lf()
    doc = Document.new("Foo bar.\nBaz quux.")
    expected = 'LF'
    assert_equal(expected, doc.eol)
  end
  def test_eol_auto_none()
    doc = Document.new("Foo bar.")
    expected = "NONE"
    assert_equal(expected, doc.eol)
  end
  def test_eol_char_lf()
    doc = Document.new("Foo bar.\nBaz quux.")
#    doc.encoding = "US-ASCII"
#    doc.eol = "LF"
    expected = "\n"
    assert_equal(expected, doc.eol_char)
  end
  def test_split_by_line()
    doc = Document.new("Hello, my name is Watanabe.\nI am just another Ruby porter.\n")
    expected = ["Hello, my name is Watanabe.\n", "I am just another Ruby porter.\n"]
    assert_equal(expected, doc.split_to_line)
  end

  # test eol split_to_line() method
  def test_cr_split_to_line()
    doc = Document.new("foo\rbar\r")
    expected = ["foo\r", "bar\r"]
    assert_equal(expected, doc.split_to_line)
  end
  def test_cr_split_to_line_chomped_lastline()
    doc = Document.new("foo\rbar")
    expected = ["foo\r", "bar"]
    assert_equal(expected, doc.split_to_line)
  end
  def test_cr_split_to_line_empty_line()
    doc = Document.new("foo\r\rbar\r")
    expected = ["foo\r", "\r", "bar\r"]
    assert_equal(expected, doc.split_to_line)
  end
  def test_lf_split_to_line()
    doc = Document.new("foo\nbar\n")
    expected = ["foo\n", "bar\n"]
    assert_equal(expected, doc.split_to_line)
  end
  def test_lf_split_to_line_chomped_lastline()
    doc = Document.new("foo\nbar")
    expected = ["foo\n", "bar"]
    assert_equal(expected, doc.split_to_line)
  end
  def test_lf_split_to_line_empty_line()
    doc = Document.new("foo\n\nbar\n")
    expected = ["foo\n", "\n", "bar\n"]
    assert_equal(expected, doc.split_to_line)
  end
  def test_crlf_split_to_line()
    doc = Document.new("foo\r\nbar\r\n")
    expected = ["foo\r\n", "bar\r\n"]
    assert_equal(expected, doc.split_to_line)
  end
  def test_crlf_split_to_line_chomped_lastline()
    doc = Document.new("foo\r\nbar")
    expected = ["foo\r\n", "bar"]
    assert_equal(expected, doc.split_to_line)
  end
  def test_crlf_split_to_line_empty_line()
    doc = Document.new("foo\r\n\r\nbar\r\n")
    expected = ["foo\r\n", "\r\n", "bar\r\n"]
    assert_equal(expected, doc.split_to_line)
  end

  # test ASCII module
  def test_ascii_split_to_word()
    doc = Document.new("foo bar")
    expected = ["foo ", "bar"]
    assert_equal(expected, doc.split_to_word)
  end
  def test_ascii_split_to_word_withsymbol()
    doc = Document.new("foo (bar) baz-baz")
    expected = ["foo ", "(bar) ", "baz-baz"]
    assert_equal(expected, doc.split_to_word)
  end
  def test_ascii_split_to_word_withquote()
    doc = Document.new("foo's 'foo' \"bar\" 'baz.'")
    expected = ["foo's ", "'foo' ", "\"bar\" ", "'baz.'"]
    assert_equal(expected, doc.split_to_word)
  end
  def test_ascii_split_to_word_withlongspace()
    doc = Document.new(" foo  bar")
    expected = [" ", "foo ", " ", "bar"]
    assert_equal(expected, doc.split_to_word)
  end
  def test_ascii_split_to_word_withdash()
    doc = Document.new("foo -- bar, baz - quux")
    expected = ["foo ", "-- ", "bar, ", "baz ", "- ", "quux"]
    assert_equal(expected, doc.split_to_word)
  end
  def test_ascii_split_to_char()
    doc = Document.new("foo bar")
    expected = ["f","o","o"," ","b","a","r"]
    assert_equal(expected, doc.split_to_char)
  end
  def test_ascii_split_to_char_with_eol_cr()
    doc = Document.new("foo bar\r")
    expected = ["f","o","o"," ","b","a","r","\r"]
    assert_equal(expected, doc.split_to_char)
  end
  def test_ascii_split_to_char_with_eol_lf()
    doc = Document.new("foo bar\n")
    expected = ["f","o","o"," ","b","a","r","\n"]
    assert_equal(expected, doc.split_to_char)
  end
  def test_ascii_split_to_char_with_eol_crlf()
    doc = Document.new("foo bar\r\n")
    expected = ["f","o","o"," ","b","a","r","\r\n"]
    assert_equal(expected, doc.split_to_char)
  end
  def test_ascii_split_to_byte()
    doc = Document.new("foo bar\r\n")
    expected = ["f","o","o"," ","b","a","r","\r","\n"]
    assert_equal(expected, doc.split_to_byte)
  end
  def test_ascii_count_byte()
    doc = Document.new("foo bar\r\n")
    expected = 9
    assert_equal(expected, doc.count_byte)
  end
  def test_ascii_count_char()
    doc = Document.new("foo bar\r\nbaz quux\r\n")
    expected = 17
    assert_equal(expected, doc.count_char)
  end
  def test_ascii_count_latin_graph_char()
    doc = Document.new("foo bar\r\nbaz quux\r\n")
    expected = 13
    assert_equal(expected, doc.count_latin_graph_char)
  end
  def test_ascii_count_graph_char()
    doc = Document.new("foo bar\r\nbaz quux\r\n")
    expected = 13
    assert_equal(expected, doc.count_graph_char)
  end
  def test_ascii_count_latin_blank_char()
    doc = Document.new("foo bar\r\nbaz\tquux\r\n")
    expected = 2
    assert_equal(expected, doc.count_latin_blank_char)
  end
  def test_ascii_count_blank_char()
    doc = Document.new("foo bar\r\nbaz\tquux\r\n")
    expected = 2
    assert_equal(expected, doc.count_blank_char)
  end
  def test_ascii_count_word()
    doc = Document.new("foo bar   \r\nbaz quux\r\n")
    expected = 6
    assert_equal(expected, doc.count_word)
  end
  def test_ascii_count_latin_word()
    doc = Document.new("foo bar   \r\nbaz quux\r\n")
    expected = 5  # "  " is also counted as a word
    assert_equal(expected, doc.count_latin_word)
  end
  def test_ascii_count_latin_valid_word()
    doc = Document.new("1 foo   \r\n%%% ()\r\n")
    expected = 2
    assert_equal(expected, doc.count_latin_valid_word)
  end
  def test_ascii_count_line()
    doc = Document.new("foo\r\nbar")
    expected = 2
    assert_equal(expected, doc.count_line)
  end
  def test_ascii_count_graph_line()
    doc = Document.new("foo\r\n ")
    expected = 1
    assert_equal(expected, doc.count_graph_line)
  end
  def test_ascii_count_empty_line()
    doc = Document.new("foo\r\n \r\n\t\r\n\r\n")
    expected = 1
    assert_equal(expected, doc.count_empty_line)
  end
  def test_ascii_count_blank_line()
    doc = Document.new("\r\n \r\n\t\r\n ")
    expected = 3
    assert_equal(expected, doc.count_blank_line)
  end

  # test EUCJP module
  def test_eucjp_split_to_word()
    doc = Document.new(NKF.nkf("-e", "���ܸ��ʸ��foo bar"))
    expected = ["���ܸ��","ʸ��","foo ","bar"].collect{|c| NKF.nkf("-e", c)}
    assert_equal(expected, doc.split_to_word)
  end
  def test_eucjp_split_to_word_kanhira()
    doc = Document.new(NKF.nkf("-e", "���ܸ��ʸ��"))
    expected = ["���ܸ��", "ʸ��"].collect{|c| NKF.nkf("-e", c)}
    assert_equal(expected, doc.split_to_word)
  end
  def test_eucjp_split_to_word_katahira()
    doc = Document.new(NKF.nkf("-e", "�������ʤ�ʸ��"))
    expected = ["�������ʤ�", "ʸ��"].collect{|c| NKF.nkf("-e", c)}
    assert_equal(expected, doc.split_to_word)
  end
  def test_eucjp_split_to_word_kataonbiki()
    doc = Document.new(NKF.nkf("-e", "��ӡ�������"), "EUC-JP")
    expected = ["��ӡ�", "����", "��"].collect{|c| NKF.nkf("-e", c)}
    assert_equal(expected, doc.split_to_word)
  end
  def test_eucjp_split_to_word_hiraonbiki()
    doc = Document.new(NKF.nkf("-e", "���ӡ���"), "EUC-JP")
    expected = (["�", "��ӡ���"]).collect{|c| NKF.nkf("-e", c)}
    assert_equal(expected, doc.split_to_word)
  end
  def test_eucjp_split_to_word_latinmix()
    doc = Document.new(NKF.nkf("-e", "���ܸ��Latin��ʸ��"))
    expected = ["���ܸ��", "Latin", "��", "ʸ��"].collect{|c| NKF.nkf("-e", c)}
    assert_equal(expected, doc.split_to_word)
  end
  def test_eucjp_split_to_char()
    doc = Document.new(NKF.nkf("-e", "���ܸ�a b"))
    expected = ["��","��","��","a"," ","b"].collect{|c|NKF.nkf("-e",c)}
    assert_equal(expected, doc.split_to_char)
  end
  def test_eucjp_split_to_char_with_cr()
    doc = Document.new(NKF.nkf("-e", "���ܸ�a b\r"))
    expected = ["��","��","��","a"," ","b","\r"].collect{|c|NKF.nkf("-e",c)}
    assert_equal(expected, doc.split_to_char)
  end
  def test_eucjp_split_to_char_with_lf()
    doc = Document.new(NKF.nkf("-e", "���ܸ�a b\n"))
    expected = ["��","��","��","a"," ","b","\n"].collect{|c|NKF.nkf("-e",c)}
    assert_equal(expected, doc.split_to_char)
  end
  def test_eucjp_split_to_char_with_crlf()
    doc = Document.new(NKF.nkf("-e", "���ܸ�a b\r\n"))
    expected = ["��","��","��","a"," ","b","\r\n"].collect{|c|NKF.nkf("-e",c)}
    assert_equal(expected, doc.split_to_char)
  end
  def test_eucjp_count_char()
    doc = Document.new(NKF.nkf("-e", "���ܸ�a b\r\n"))
    expected = 7
    assert_equal(expected, doc.count_char)
  end
  def test_eucjp_count_latin_graph_char()
    doc = Document.new(NKF.nkf("-e", "���ܸ�a b\r\n"))
    expected = 2
    assert_equal(expected, doc.count_latin_graph_char)
  end
  def test_eucjp_count_ja_graph_char()
    doc = Document.new(NKF.nkf("-e", "���ܸ�a b\r\n"))
    expected = 3
    assert_equal(expected, doc.count_ja_graph_char)
  end
  def test_eucjp_count_graph_char()
    doc = Document.new(NKF.nkf("-e", "���ܸ�a b\r\n"))
    expected = 5
    assert_equal(expected, doc.count_graph_char)
  end
  def test_eucjp_count_latin_blank_char()
    doc = Document.new(NKF.nkf("-e", "���ܸ�\ta b\r\n"))
    expected = 2
    assert_equal(expected, doc.count_latin_blank_char)
  end
  def test_eucjp_count_ja_blank_char()
    doc = Document.new(NKF.nkf("-e", "���ܡ���\ta b\r\n"))
    expected = 1
    assert_equal(expected, doc.count_ja_blank_char)
  end
  def test_eucjp_count_blank_char()
    doc = Document.new(NKF.nkf("-e", "���ܡ���\ta b\r\n"))
    expected = 3
    assert_equal(expected, doc.count_blank_char)
  end
  def test_eucjp_count_word()
    doc = Document.new(NKF.nkf("-e", "���ܡ���a b --\r\n"))
    expected = 7 # "--" and "\r\n" are counted as word here (though not "valid")
    assert_equal(expected, doc.count_word)
  end
  def test_eucjp_count_ja_word()
    doc = Document.new(NKF.nkf("-e", "���ܡ���a b --\r\n"))
    expected = 3
    assert_equal(expected, doc.count_ja_word)
  end
  def test_eucjp_count_latin_valid_word()
    doc = Document.new(NKF.nkf("-e", "���ܡ���a b --\r\n"))
    expected = 2
    assert_equal(expected, doc.count_latin_valid_word)
  end
  def test_eucjp_count_ja_valid_word()
    doc = Document.new(NKF.nkf("-e", "���ܡ���a b --\r\n"))
    expected = 2
    assert_equal(expected, doc.count_ja_valid_word)
  end
  def test_eucjp_count_valid_word()
    doc = Document.new(NKF.nkf("-e", "���ܡ���a b --\r\n"))
    expected = 4
    assert_equal(expected, doc.count_valid_word)
  end
  def test_eucjp_count_line()
    doc = Document.new(NKF.nkf("-e", "���ܸ�\r\n��\r\n \r\n\r\nfoo\r\nbar"))
    expected = 6
    assert_equal(expected, doc.count_line)
  end
  def test_eucjp_count_graph_line()
    doc = Document.new(NKF.nkf("-e", "���ܸ�\r\n��\r\n \r\n\r\nfoo\r\nbar"))
    expected = 3
    assert_equal(expected, doc.count_graph_line)
  end
  def test_eucjp_count_empty_line()
    doc = Document.new(NKF.nkf("-e", "���ܸ�\r\n��\r\n \r\n\r\nfoo\r\nbar"))
    expected = 1
    assert_equal(expected, doc.count_empty_line)
  end
  def test_eucjp_count_blank_line()
    doc = Document.new(NKF.nkf("-e", "���ܸ�\r\n��\r\n \r\n\r\nfoo\r\nbar"))
    expected = 2
    assert_equal(expected, doc.count_blank_line)
  end

  # test SJIS module
  def test_sjis_split_to_word()
    doc = Document.new(NKF.nkf("-s", "���ܸ��ʸ��foo bar"))
    expected = ["���ܸ��", "ʸ��", "foo ", "bar"].collect{|c|NKF.nkf("-s",c)}
    assert_equal(expected, doc.split_to_word)
  end
  def test_sjisplit_s_to_word_kanhira()
    doc = Document.new(NKF.nkf("-s", "���ܸ��ʸ��"))
    expected = ["���ܸ��", "ʸ��"].collect{|c| NKF.nkf("-s", c)}
    assert_equal(expected, doc.split_to_word)
  end
  def test_sjis_split_to_word_katahira()
    doc = Document.new(NKF.nkf("-s", "�������ʤ�ʸ��"))
    expected = ["�������ʤ�", "ʸ��"].collect{|c| NKF.nkf("-s", c)}
    assert_equal(expected, doc.split_to_word)
  end
  def test_sjis_split_to_word_kataonbiki()
    doc = Document.new(NKF.nkf("-s", "��ӡ��λ���"))
    expected = ["��ӡ���", "����"].collect{|c| NKF.nkf("-s", c)}
    assert_equal(expected, doc.split_to_word)
  end
  def test_sjis_split_to_word_hiraonbiki()
    doc = Document.new(NKF.nkf("-s", "���ӡ���"))
    expected = ["�", "��ӡ���"].collect{|c| NKF.nkf("-s", c)}
    assert_equal(expected, doc.split_to_word)
  end
  def test_sjis_split_to_word_latinmix()
    doc = Document.new(NKF.nkf("-s", "���ܸ��Latin��ʸ��"))
    expected = ["���ܸ��","Latin","��","ʸ��"].collect{|c| NKF.nkf("-s", c)}
    assert_equal(expected, doc.split_to_word)
  end
  def test_sjis_split_to_char()
    doc = Document.new(NKF.nkf("-s", "ɽ�׻�a b"))
    expected = ["ɽ","��","��","a"," ","b"].collect{|c|NKF.nkf("-s",c)}
    assert_equal(expected, doc.split_to_char)
  end
  def test_sjis_split_to_char_with_cr()
    doc = Document.new(NKF.nkf("-s", "ɽ�׻�a b\r"))
    expected = ["ɽ","��","��","a"," ","b","\r"].collect{|c|NKF.nkf("-s",c)}
    assert_equal(expected, doc.split_to_char)
  end
  def test_sjis_split_to_char_with_lf()
    doc = Document.new(NKF.nkf("-s", "ɽ�׻�a b\n"))
    expected = ["ɽ","��","��","a"," ","b","\n"].collect{|c|NKF.nkf("-s",c)}
    assert_equal(expected, doc.split_to_char)
  end
  def test_sjis_split_to_char_with_crlf()
    doc = Document.new(NKF.nkf("-s", "ɽ�׻�a b\r\n"))
    expected = ["ɽ","��","��","a"," ","b","\r\n"].collect{|c|NKF.nkf("-s",c)}
    assert_equal(expected, doc.split_to_char)
  end
  def test_sjis_count_char()
    doc = Document.new(NKF.nkf("-s", "���ܸ�a b\r\n"))
    expected = 7
    assert_equal(expected, doc.count_char)
  end
  def test_sjis_count_latin_graph_char()
    doc = Document.new(NKF.nkf("-s", "���ܸ�a b\r\n"))
    expected = 2
    assert_equal(expected, doc.count_latin_graph_char)
  end
  def test_sjis_count_ja_graph_char()
    doc = Document.new(NKF.nkf("-s", "���ܸ�a b\r\n"))
    expected = 3
    assert_equal(expected, doc.count_ja_graph_char)
  end
  def test_sjis_count_graph_char()
    doc = Document.new(NKF.nkf("-s", "���ܸ�a b\r\n"))
    expected = 5
    assert_equal(expected, doc.count_graph_char)
  end
  def test_sjis_count_latin_blank_char()
    doc = Document.new(NKF.nkf("-s", "���ܸ�\ta b\r\n"))
    expected = 2
    assert_equal(expected, doc.count_latin_blank_char)
  end
  def test_sjis_count_ja_blank_char()
    doc = Document.new(NKF.nkf("-s", "���ܡ���\ta b\r\n"))
    expected = 1
    assert_equal(expected, doc.count_ja_blank_char)
  end
  def test_sjis_count_blank_char()
    doc = Document.new(NKF.nkf("-s", "���ܡ���\ta b\r\n"))
    expected = 3
    assert_equal(expected, doc.count_blank_char)
  end
  def test_sjis_count_word()
    doc = Document.new(NKF.nkf("-s", "���ܡ���a b --\r\n"))
    expected = 7 # "--" and "\r\n" are counted as word here (though not "valid")
    assert_equal(expected, doc.count_word)
  end
  def test_sjis_count_ja_word()
    doc = Document.new(NKF.nkf("-s", "���ܡ���a b --\r\n"))
    expected = 3
    assert_equal(expected, doc.count_ja_word)
  end
  def test_sjis_count_latin_valid_word()
    doc = Document.new(NKF.nkf("-s", "���ܡ���a b --\r\n"))
    expected = 2
    assert_equal(expected, doc.count_latin_valid_word)
  end
  def test_sjis_count_ja_valid_word()
    doc = Document.new(NKF.nkf("-s", "���ܡ���a b --\r\n"))
    expected = 2
    assert_equal(expected, doc.count_ja_valid_word)
  end
  def test_sjis_count_valid_word()
    doc = Document.new(NKF.nkf("-s", "���ܡ���a b --\r\n"))
    expected = 4
    assert_equal(expected, doc.count_valid_word)
  end
  def test_sjis_count_line()
    doc = Document.new(NKF.nkf("-s", "���ܸ�\r\n��\r\n \r\n\r\nfoo\r\nbar"))
    expected = 6
    assert_equal(expected, doc.count_line)
  end
  def test_sjis_count_graph_line()
    doc = Document.new(NKF.nkf("-s", "���ܸ�\r\n��\r\n \r\n\r\nfoo\r\nbar"))
    expected = 3
    assert_equal(expected, doc.count_graph_line)
  end
  def test_sjis_count_empty_line()
    doc = Document.new(NKF.nkf("-s", "���ܸ�\r\n��\r\n \r\n\r\nfoo\r\nbar"))
    expected = 1
    assert_equal(expected, doc.count_empty_line)
  end
  def test_sjis_count_blank_line()
    doc = Document.new(NKF.nkf("-s", "���ܸ�\r\n��\r\n \r\n\r\nfoo\r\nbar"))
    expected = 2
    assert_equal(expected, doc.count_blank_line)
  end

  # test UTF8 module
  def test_utf8_split_to_word()
    doc = Document.new(NKF.nkf("-E -w", "���ܸ��ʸ��foo bar"))
    expected = ["���ܸ��", "ʸ��", "foo ", "bar"].collect{|c| NKF.nkf("-E -w", c)}
    assert_equal(expected, doc.split_to_word)
  end
  def test_utf8_split_to_word_kanhira()
    doc = Document.new(NKF.nkf("-E -w", "���ܸ��ʸ��"))
    expected = ["���ܸ��", "ʸ��"].collect{|c| NKF.nkf("-E -w", c)}
    assert_equal(expected, doc.split_to_word)
  end
  def test_utf8_split_to_word_katahira()
    doc = Document.new(NKF.nkf("-E -w", "�������ʤ�ʸ��"))
    expected = ["�������ʤ�", "ʸ��"].collect{|c| NKF.nkf("-E -w", c)}
    assert_equal(expected, doc.split_to_word)
  end
  def test_utf8_split_to_word_kataonbiki()
    doc = Document.new(NKF.nkf("-E -w", "��ӡ��λ���"))
    expected = ["��ӡ���", "����"].collect{|c| NKF.nkf("-E -w", c)}
    assert_equal(expected, doc.split_to_word)
  end
  def test_utf8_split_to_word_hiraonbiki()
    doc = Document.new(NKF.nkf("-E -w", "���ӡ���"))
    expected = ["�", "��ӡ���"].collect{|c| NKF.nkf("-E -w", c)}
    assert_equal(expected, doc.split_to_word)
  end
  def test_utf8_split_to_word_latinmix()
    doc = Document.new(NKF.nkf("-E -w", "���ܸ��Latin��ʸ��"))
    expected = ["���ܸ��", "Latin", "��", "ʸ��"].collect{|c| NKF.nkf("-E -w", c)}
    assert_equal(expected, doc.split_to_word)
  end
  def test_utf8_split_to_char()
    doc = Document.new(NKF.nkf("-E -w", "���ܸ�a b"), "UTF-8")
    expected = ["��", "��", "��", "a", " ", "b"].collect{|c| NKF.nkf("-E -w", c)}
    assert_equal(expected, doc.split_to_char)
  end
  def test_utf8_split_to_char_with_cr()
    doc = Document.new(NKF.nkf("-E -w", "���ܸ�a b\r"), "UTF-8")
    expected = ["��","��","��","a"," ","b","\r"].collect{|c| NKF.nkf("-E -w", c)}
    assert_equal(expected, doc.split_to_char)
  end
  def test_utf8_split_to_char_with_lf()
    doc = Document.new(NKF.nkf("-E -w", "���ܸ�a b\n"), "UTF-8")
    expected = ["��","��","��","a"," ","b","\n"].collect{|c| NKF.nkf("-E -w", c)}
    assert_equal(expected, doc.split_to_char)
  end
  def test_utf8_split_to_char_with_crlf()
    doc = Document.new(NKF.nkf("-E -w", "���ܸ�a b\r\n"), "UTF-8")
    expected = ["��","��","��","a"," ","b","\r\n"].collect{|c| NKF.nkf("-E -w", c)}
    assert_equal(expected, doc.split_to_char)
  end
  def test_utf8_count_char()
    doc = Document.new(NKF.nkf("-E -w", "���ܸ�a b\r\n"), "UTF-8")
    expected = 7
    assert_equal(expected, doc.count_char)
  end
  def test_utf8_count_latin_graph_char()
    doc = Document.new(NKF.nkf("-E -w", "���ܸ�a b\r\n"), "UTF-8")
    expected = 2
    assert_equal(expected, doc.count_latin_graph_char)
  end
  def test_utf8_count_ja_graph_char()
    doc = Document.new(NKF.nkf("-E -w", "���ܸ�a b\r\n"), "UTF-8")
    expected = 3
    assert_equal(expected, doc.count_ja_graph_char)
  end
  def test_utf8_count_graph_char()
    doc = Document.new(NKF.nkf("-E -w", "���ܸ�a b\r\n"), "UTF-8")
    expected = 5
    assert_equal(expected, doc.count_graph_char)
  end
  def test_utf8_count_latin_blank_char()
    doc = Document.new(NKF.nkf("-E -w", "���ܸ�\ta b\r\n"))
    expected = 2
    assert_equal(expected, doc.count_latin_blank_char)
  end
  def test_utf8_count_ja_blank_char()
    doc = Document.new(NKF.nkf("-E -w", "���ܡ���\ta b\r\n"))
    expected = 1
    assert_equal(expected, doc.count_ja_blank_char)
  end
  def test_utf8_count_blank_char()
    doc = Document.new(NKF.nkf("-E -w", "���ܡ���\ta b\r\n"))
    expected = 3
    assert_equal(expected, doc.count_blank_char)
  end
  def test_utf8_count_word()
    doc = Document.new(NKF.nkf("-E -w", "���ܡ���a b --\r\n"))
    expected = 7 # "--" and "\r\n" are counted as word here (though not "valid")
    assert_equal(expected, doc.count_word)
  end
  def test_utf8_count_ja_word()
    doc = Document.new(NKF.nkf("-E -w", "���ܡ���a b --\r\n"))
    expected = 3
    assert_equal(expected, doc.count_ja_word)
  end
  def test_utf8_count_latin_valid_word()
    doc = Document.new(NKF.nkf("-E -w", "���ܡ���a b --\r\n"))
    expected = 2
    assert_equal(expected, doc.count_latin_valid_word)
  end
  def test_utf8_count_ja_valid_word()
    doc = Document.new(NKF.nkf("-E -w", "���ܡ���a b --\r\n"))
    expected = 2
    assert_equal(expected, doc.count_ja_valid_word)
  end
  def test_utf8_count_valid_word()
    doc = Document.new(NKF.nkf("-E -w", "���ܡ���a b --\r\n"))
    expected = 4
    assert_equal(expected, doc.count_valid_word)
  end
  def test_utf8_count_line()
    doc = Document.new(NKF.nkf("-E -w", "���ܸ�\r\n��\r\n \r\n\r\nfoo\r\nbar"))
    expected = 6
    assert_equal(expected, doc.count_line)
  end
  def test_utf8_count_graph_line()
    doc = Document.new(NKF.nkf("-E -w", "���ܸ�\r\n��\r\n \r\n\r\nfoo\r\nbar"))
    expected = 3
    assert_equal(expected, doc.count_graph_line)
  end
  def test_utf8_count_empty_line()
    doc = Document.new(NKF.nkf("-E -w", "���ܸ�\r\n��\r\n \r\n\r\nfoo\r\nbar"))
    expected = 1
    assert_equal(expected, doc.count_empty_line)
  end
  def test_utf8_count_blank_line()
    doc = Document.new(NKF.nkf("-E -w", "���ܸ�\r\n��\r\n \r\n\r\nfoo\r\nbar"))
    expected = 2
    assert_equal(expected, doc.count_blank_line)
  end




  def teardown()
    #
  end

end
