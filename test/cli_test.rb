#!/usr/bin/ruby
# -*- coding: us-ascii; -*-

require 'test/unit'
require 'docdiff/cli'

class TC_CLI < Test::Unit::TestCase
  def test_parse_options!()
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

  def test_parse_config_file_content()
    content = ["# comment line\n",
               " # comment line with leading space\n",
               "foo1 = bar\n",
               "foo2 = bar baz \n",
               " foo3  =  123 # comment\n",
               "foo4 = no    \n",
               "foo1 = tRue\n",
               "\n",
               "",
               nil].join
    expected = {:foo1=>true, :foo2=>"bar baz", :foo3=>123, :foo4=>false}
    assert_equal(expected, DocDiff::CLI.parse_config_file_content(content))
  end

  def test_read_config_from_file()
    filename = File.join(File.dirname(__FILE__), "fixture/simple.conf")
    expected = {:foo1 => true, :foo2 => "bar baz", :foo3 => 123, :foo4 => false}
    config, _message = DocDiff::CLI.read_config_from_file(filename)
    assert_equal(expected, config)
  end

  def test_cli()
    expected = "Hello, my name is [-Watanabe.-]{+matz.+}\n"
    cmd = "ruby -I lib bin/docdiff --wdiff" +
      " test/fixture/01_en_ascii_lf.txt test/fixture/02_en_ascii_lf.txt"
    actual = `#{cmd}`.scan(/^.*?$\n/m).first
    assert_equal(expected, actual)
  end
end
