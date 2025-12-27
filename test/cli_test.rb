#!/usr/bin/ruby
# -*- coding: utf-8; -*-

require "test/unit"
require "nkf"
require "docdiff/cli"

class TC_CLI < Test::Unit::TestCase
  def test_parse_options!
    args = [
      "--resolution=line",
      "--char",
      "--encoding=ASCII",
      "--eucjp",
      "--eol=CR",
      "--crlf",
      "--format=manued",
      "--wdiff",
      "--label=old",
      "--label=new",
      "--digest",
      "--display=block",
      "--pager='less --raw-control-chars'",
      "--no-config-file",
      "--config-file=./docdiff.conf",
      "file1",
      "file2",
    ]
    expected = {
      :resolution => "char",
      :encoding => "EUC-JP",
      :eol => "CRLF",
      :format => "wdiff",
      :digest => true,
      :label => ["old", "new"],
      :display => "block",
      :pager => "'less --raw-control-chars'",
      :no_config_file => true,
      :config_file => "./docdiff.conf",
    }
    assert_equal(expected, DocDiff::CLI.parse_options!(args, base_options: {}))
  end

  def test_parse_config_file_content
    content = [
      "# comment line\n",
      " # comment line with leading space\n",
      "foo1 = bar\n",
      "foo2 = bar baz \n",
      " foo3  =  123 # comment\n",
      "foo4 = no    \n",
      "foo1 = tRue\n",
      "\n",
      "",
      nil,
    ].join
    expected = {:foo1 => true, :foo2 => "bar baz", :foo3 => 123, :foo4 => false}
    assert_equal(expected, DocDiff::CLI.parse_config_file_content(content))
  end

  def test_read_config_from_file
    filename = File.join(File.dirname(__FILE__), "fixture/simple.conf")
    expected = {:foo1 => true, :foo2 => "bar baz", :foo3 => 123, :foo4 => false}
    config, _message = DocDiff::CLI.read_config_from_file(filename)
    assert_equal(expected, config)
  end

  def test_read_config_from_file_raises_exception
    assert_raise(Errno::ENOENT) do
      config, message = DocDiff::CLI.read_config_from_file("no/such/file")
    end
  end

  def test_cli_resolution_line
    expected = <<~EOS.chomp
      [-Hello, my name is Watanabe.
      I am just another Ruby porter.
      -]{+Hello, my name is matz.
      It's me who has created Ruby.  I am a Ruby hacker.
      +}
    EOS
    cmd = "ruby -I lib bin/docdiff --resolution=line --format=wdiff" \
      " test/fixture/01_en_ascii_lf.txt test/fixture/02_en_ascii_lf.txt"
    actual = `#{cmd}`
    assert_equal(expected, actual)
  end

  def test_cli_resolution_word
    expected = <<~EOS
      Hello, my name is [-Watanabe.-]{+matz.+}
      {+It's me who has created Ruby.  +}I am [-just another -]{+a +}Ruby [-porter.-]{+hacker.+}
    EOS
    cmd = "ruby -I lib bin/docdiff --resolution=word --format=wdiff" \
      " test/fixture/01_en_ascii_lf.txt test/fixture/02_en_ascii_lf.txt"
    actual = `#{cmd}`
    assert_equal(expected, actual)
  end

  def test_cli_resolution_char
    expected = <<~EOS
      Hello, my name is [-W-]{+m+}at[-anabe-]{+z+}.
      {+It's me who has created Ruby.  +}I am [-just -]a[-nother-] Ruby [-port-]{+hack+}er.
    EOS
    cmd = "ruby -I lib bin/docdiff --resolution=char --format=wdiff" \
      " test/fixture/01_en_ascii_lf.txt test/fixture/02_en_ascii_lf.txt"
    actual = `#{cmd}`
    assert_equal(expected, actual)
  end

  def test_cli_encoding_ascii
    expected = <<~EOS
      Hello, my name is [-Watanabe.-]{+matz.+}
      {+It's me who has created Ruby.  +}I am [-just another -]{+a +}Ruby [-porter.-]{+hacker.+}
    EOS
    cmd = "ruby -I lib bin/docdiff --encoding=ASCII --format=wdiff" \
      " test/fixture/01_en_ascii_lf.txt test/fixture/02_en_ascii_lf.txt"
    actual = `#{cmd}`
    assert_equal(expected, actual)
  end

  def test_cli_encoding_euc_jp
    expected = NKF.nkf("--ic=UTF-8 --oc=EUC-JP", <<~EOS)
      [-こんにちは-]{+こんばんは+}、私の[-名前はわたなべです-]{+名前はまつもとです+}。
      {+Rubyを作ったのは私です。+}私は[-Just Another -]Ruby [-Porter-]{+Hacker+}です。
    EOS
    cmd = "ruby --external-encoding EUC-JP -I lib bin/docdiff --encoding=EUC-JP --format=wdiff" \
      " test/fixture/01_ja_eucjp_lf.txt test/fixture/02_ja_eucjp_lf.txt"
    actual = `#{cmd}`.force_encoding("EUC-JP")
    assert_equal(expected, actual)
  end

  def test_cli_encoding_shift_jis
    expected_utf8_cr =
      "[-こんにちは-]{+こんばんは+}、私の[-名前はわたなべです-]{+名前はまつもとです+}。\r" \
        "{+Rubyを作ったのは私です。+}私は[-Just Another -]Ruby [-Porter-]{+Hacker+}です。\r"
    expected = NKF.nkf("--ic=UTF-8 --oc=Shift_JIS", expected_utf8_cr)
    cmd = "ruby --external-encoding Shift_JIS -I lib bin/docdiff --encoding=Shift_JIS --format=wdiff" \
      " test/fixture/01_ja_sjis_cr.txt test/fixture/02_ja_sjis_cr.txt"
    actual = `#{cmd}`.force_encoding("Shift_JIS")
    assert_equal(expected, actual)
  end

  def test_cli_encoding_utf_8
    expected = <<~EOS
      [-こんにちは-]{+こんばんは+}、私の[-名前はわたなべです-]{+名前はまつもとです+}。
      {+Rubyを作ったのは私です。+}私は[-Just Another -]Ruby [-Porter-]{+Hacker+}です。
    EOS
    cmd = "ruby -I lib bin/docdiff --encoding=UTF-8 --format=wdiff" \
      " test/fixture/01_ja_utf8_lf.txt test/fixture/02_ja_utf8_lf.txt"
    actual = `#{cmd}`.force_encoding("UTF-8")
    assert_equal(expected, actual)
  end

  def test_cli_eol_cr
    expected =
      "Hello, my name is [-Watanabe.-]{+matz.+}\r" \
        "{+It's me who has created Ruby.  +}I am [-just another -]{+a +}Ruby [-porter.-]{+hacker.+}\r"
    cmd = "ruby -I lib bin/docdiff --eol=CR --format=wdiff" \
      " test/fixture/01_en_ascii_cr.txt test/fixture/02_en_ascii_cr.txt"
    actual = `#{cmd}`
    assert_equal(expected, actual)
  end

  def test_cli_eol_lf
    expected =
      "Hello, my name is [-Watanabe.-]{+matz.+}\n" \
        "{+It's me who has created Ruby.  +}I am [-just another -]{+a +}Ruby [-porter.-]{+hacker.+}\n"
    cmd = "ruby -I lib bin/docdiff --eol=LF --format=wdiff" \
      " test/fixture/01_en_ascii_lf.txt test/fixture/02_en_ascii_lf.txt"
    actual = `#{cmd}`
    assert_equal(expected, actual)
  end

  def test_cli_eol_crlf
    expected =
      "Hello, my name is [-Watanabe.-]{+matz.+}\r\n" \
        "{+It's me who has created Ruby.  +}I am [-just another -]{+a +}Ruby [-porter.-]{+hacker.+}\r\n"
    cmd = "ruby -I lib bin/docdiff --eol=CRLF --format=wdiff" \
      " test/fixture/01_en_ascii_crlf.txt test/fixture/02_en_ascii_crlf.txt"
    actual = `#{cmd}`
    assert_equal(expected, actual)
  end

  def test_cli_format_html
    expected = <<~EOS
      <span class="common">Hello, my name is </span>\
      <span class="before-change"><del>Watanabe.</del></span>\
      <span class="after-change"><ins>matz.</ins></span>\
      <span class="common"><br />
    EOS
    cmd = "ruby -I lib bin/docdiff --format=html" \
      " test/fixture/01_en_ascii_lf.txt test/fixture/02_en_ascii_lf.txt"
    actual = `#{cmd}`.scan(/^.*?$\n/m)[-4]
    assert_equal(expected, actual)
  end

  def test_cli_format_manued
    expected = "Hello, my name is [Watanabe./matz.]\n"
    cmd = "ruby -I lib bin/docdiff --format=manued" \
      " test/fixture/01_en_ascii_lf.txt test/fixture/02_en_ascii_lf.txt"
    actual = `#{cmd}`.scan(/^.*?$\n/m)[-2]
    assert_equal(expected, actual)
  end

  def test_cli_format_tty
    expected = "Hello, my name is \e[7;4;33mWatanabe.\e[0m\e[7;1;32mmatz.\e[0m\n"
    cmd = "ruby -I lib bin/docdiff --format=tty" \
      " test/fixture/01_en_ascii_lf.txt test/fixture/02_en_ascii_lf.txt"
    actual = `#{cmd}`.scan(/^.*?$\n/m).first
    assert_equal(expected, actual)
  end

  def test_cli_format_wdiff
    expected = "Hello, my name is [-Watanabe.-]{+matz.+}\n"
    cmd = "ruby -I lib bin/docdiff --format=wdiff" \
      " test/fixture/01_en_ascii_lf.txt test/fixture/02_en_ascii_lf.txt"
    actual = `#{cmd}`.scan(/^.*?$\n/m).first
    assert_equal(expected, actual)
  end

  def test_cli_digest
    expected = <<~EOS
      ----
      1,1
      Hello, my name is [-Watanabe.-]{+matz.+}

      ----
      (2),2

      {+It's me who has created Ruby.  +}I am#{" "}
      ----
      2,2
      I am [-just another -]{+a +}Ruby#{" "}
      ----
      2,2
      Ruby [-porter.-]{+hacker.+}

      ----
    EOS
    cmd = "ruby -I lib bin/docdiff --digest --format=wdiff" \
      " test/fixture/01_en_ascii_lf.txt test/fixture/02_en_ascii_lf.txt"
    actual = `#{cmd}`.force_encoding("UTF-8")
    assert_equal(expected, actual)
  end

  def test_cli_display_inline
    expected = <<~EOS
      ----
      1,1
      Hello, my name is [-Watanabe.-]{+matz.+}

      ----
      (2),2

      {+It's me who has created Ruby.  +}I am#{" "}
      ----
      2,2
      I am [-just another -]{+a +}Ruby#{" "}
      ----
      2,2
      Ruby [-porter.-]{+hacker.+}

      ----
    EOS
    cmd = "ruby -I lib bin/docdiff --digest --display=inline --format=wdiff" \
      " test/fixture/01_en_ascii_lf.txt test/fixture/02_en_ascii_lf.txt"
    actual = `#{cmd}`.force_encoding("UTF-8")
    assert_equal(expected, actual)
  end

  def test_cli_display_block
    expected = <<~EOS
      ----
      1,1
      Hello, my name is [-Watanabe.-]

      Hello, my name is {+matz.+}

      ----
      (2),2

      I am#{" "}

      {+It's me who has created Ruby.  +}I am#{" "}
      ----
      2,2
      I am [-just another -]Ruby#{" "}
      I am {+a +}Ruby#{" "}
      ----
      2,2
      Ruby [-porter.-]

      Ruby {+hacker.+}

      ----
    EOS
    cmd = "ruby -I lib bin/docdiff --digest --display=block --format=wdiff" \
      " test/fixture/01_en_ascii_lf.txt test/fixture/02_en_ascii_lf.txt"
    actual = `#{cmd}`.force_encoding("UTF-8")
    assert_equal(expected, actual)
  end

  def test_cli_config_file_format_wdiff
    config_file_name = File.join(File.dirname(__FILE__), "fixture/format_wdiff.conf")
    expected = <<~EOS
      Hello, my name is [-Watanabe.-]{+matz.+}
      {+It's me who has created Ruby.  +}I am [-just another -]{+a +}Ruby [-porter.-]{+hacker.+}
    EOS
    cmd = "ruby -I lib bin/docdiff --config-file=#{config_file_name}" \
      " test/fixture/01_en_ascii_lf.txt test/fixture/02_en_ascii_lf.txt"
    actual = `#{cmd}`
    assert_equal(expected, actual)
  end
end
