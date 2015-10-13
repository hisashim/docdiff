#!/usr/bin/ruby
# -*- coding: us-ascii; -*-
require 'test/unit'
require 'docdiff'
require 'nkf'

class TC_DocDiff_Document < Test::Unit::TestCase
  Document = DocDiff::Document

  def setup()
    #
  end

  def test_compare_by_line()
    doc1 = Document.new("Foo bar.\nBaz quux.", 'US-ASCII', 'LF')
    doc2 = Document.new("Foo.\nBaz quux.", 'US-ASCII', 'LF')
    docdiff = DocDiff.new
    expected = [[:change_elt,     ["Foo bar.\n"], ["Foo.\n"]],
                [:common_elt_elt, ['Baz quux.'], ['Baz quux.']]]
    assert_equal(expected, docdiff.compare_by_line(doc1, doc2))
  end
  def test_compare_by_line_word()
    doc1 = Document.new("a b c d\ne f", 'US-ASCII', 'LF')
    doc2 = Document.new("a x c d\ne f", 'US-ASCII', 'LF')
    docdiff = DocDiff.new
    expected = [[:common_elt_elt, ["a "], ["a "]],
                [:change_elt,     ["b "], ["x "]],
                [:common_elt_elt, ["c ", "d", "\n"], ["c ", "d", "\n"]],
                [:common_elt_elt, ["e f"], ["e f"]]]
    assert_equal(expected,
                 docdiff.compare_by_line_word(doc1, doc2))
  end
  def test_compare_by_line_word_char()
    doc1 = Document.new("foo bar\nbaz", 'US-ASCII', 'LF')
    doc2 = Document.new("foo beer\nbaz", 'US-ASCII', 'LF')
    docdiff = DocDiff.new
    expected = [[:common_elt_elt, ['foo '], ['foo ']],
                [:common_elt_elt, ['b'], ['b']],
                [:change_elt,     ['a'], ['e', 'e']],
                [:common_elt_elt, ['r'], ['r']],
                [:common_elt_elt, ["\n"], ["\n"]],
                [:common_elt_elt, ['baz'], ['baz']]]
    assert_equal(expected,
                 docdiff.compare_by_line_word_char(doc1, doc2))
  end

  def test_run_line_html()
    doc1 = Document.new("foo bar\nbaz", 'US-ASCII', 'LF')
    doc2 = Document.new("foo beer\nbaz", 'US-ASCII', 'LF')
    docdiff = DocDiff.new
    expected = '<?xml version="1.0" encoding="US-ASCII"?>' + "\n" +
     '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"' + "\n" +
     '"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">' + "\n" +
     '<html><head>' + "\n" +
     '<meta http-equiv="Content-Type" content="text/html; charset=US-ASCII" />' + "\n" +
     '<title>Difference</title>' + "\n" +
     '<style type="text/css">' + "\n" +
     ' body {font-family: monospace;}' + "\n" +
     ' span.del {background: hotpink; border: thin inset;}' + "\n" +
     ' span.add {background: deepskyblue; font-weight: bolder; border: thin outset;}' + "\n" +
     ' span.before-change {background: yellow; border: thin inset;}' + "\n" +
     ' span.after-change {background: lime; font-weight: bolder; border: thin outset;}' + "\n" +
     " li.entry .position {font-weight: bolder; margin-top: 0em; margin-bottom: 0em; padding-top: 0.5em; padding-bottom: 0em;}\n" +
     " li.entry .body {margin-top: 0em; margin-bottom: 0em; padding-top: 0em; padding-bottom: 0.5em;}\n" +
     " li.entry {border-top: thin solid gray;}\n" +
     '</style>' + "\n" +
     '</head><body><div>' + "\n" +
     '<span class="before-change"><del>foo bar<br />' + "\n" + '</del></span>' +
     '<span class="after-change"><ins>foo beer<br />' + "\n" + '</ins></span>' +
     '<span class="common">baz' + "</span>" + "\n</div></body></html>" + "\n"
    assert_equal(expected, docdiff.run(doc1, doc2, {:resolution => "line", :format => "html", :digest => false}))
  end

  def test_run_line_manued()
    doc1 = Document.new("foo bar\nbaz", 'US-ASCII', 'LF')
    doc2 = Document.new("foo beer\nbaz", 'US-ASCII', 'LF')
    docdiff = DocDiff.new
    expected = "defparentheses [ ]\n" +
               "defdelete      /\n" +
               "defswap        |\n" +
               "defcomment     ;\n" +
               "defescape      ~\n" +
               "deforder       newer-last\n" +
               "defversion     0.9.5\n" + 
               "[foo bar\n/foo beer\n]baz"
    assert_equal(expected, docdiff.run(doc1, doc2, {:resolution => "line", :format => "manued", :digest => false}))
  end
  def test_run_word_manued()
    doc1 = Document.new("foo bar\nbaz", 'US-ASCII', 'LF')
    doc2 = Document.new("foo beer\nbaz", 'US-ASCII', 'LF')
    docdiff = DocDiff.new
    expected = "defparentheses [ ]\n" +
               "defdelete      /\n" +
               "defswap        |\n" +
               "defcomment     ;\n" +
               "defescape      ~\n" +
               "deforder       newer-last\n" +
               "defversion     0.9.5\n" + 
               "foo [bar/beer]\nbaz"
    assert_equal(expected, docdiff.run(doc1, doc2, {:resolution => "word", :format => "manued", :digest => false}))
  end
  def test_run_char_manued()
    doc1 = Document.new("foo bar\nbaz", 'US-ASCII', 'LF')
    doc2 = Document.new("foo beer\nbaz", 'US-ASCII', 'LF')
    docdiff = DocDiff.new
    expected = "defparentheses [ ]\n" +
               "defdelete      /\n" +
               "defswap        |\n" +
               "defcomment     ;\n" +
               "defescape      ~\n" +
               "deforder       newer-last\n" +
               "defversion     0.9.5\n" + 
               "foo b[a/ee]r\nbaz"
    assert_equal(expected, docdiff.run(doc1, doc2, {:resolution => "char", :format => "manued", :digest => false}))
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
    docdiff = DocDiff.new
    assert_equal(expected,
                 DocDiff.parse_config_file_content(content))
  end

  def test_run_line_user()
    doc1 = Document.new("foo bar\nbaz", 'US-ASCII', 'LF')
    doc2 = Document.new("foo beer\nbaz", 'US-ASCII', 'LF')
    config = {:tag_common_start          => '<=>',
              :tag_common_end            => '</=>',
              :tag_del_start             => '<->',
              :tag_del_end               => '</->',
              :tag_add_start             => '<+>',
              :tag_add_end               => '</+>',
              :tag_change_before_start   => '<!->',
              :tag_change_before_end     => '</!->',
              :tag_change_after_start    => '<!+>',
              :tag_change_after_end      => '</!+>'}
    docdiff = DocDiff.new
    docdiff.config.update(config)
    expected = "<!->foo bar\n</!-><!+>foo beer\n</!+><=>baz</=>"
    assert_equal(expected, docdiff.run(doc1, doc2, {:resolution => "line", :format => "user", :digest => false}))
  end
  def test_run_word_user()
    doc1 = Document.new("foo bar\nbaz", 'US-ASCII', 'LF')
    doc2 = Document.new("foo beer\nbaz", 'US-ASCII', 'LF')
    config = {:tag_common_start          => '<=>',
              :tag_common_end            => '</=>',
              :tag_del_start             => '<->',
              :tag_del_end               => '</->',
              :tag_add_start             => '<+>',
              :tag_add_end               => '</+>',
              :tag_change_before_start   => '<!->',
              :tag_change_before_end     => '</!->',
              :tag_change_after_start    => '<!+>',
              :tag_change_after_end      => '</!+>'}
    docdiff = DocDiff.new
    docdiff.config.update(config)
    expected = "<=>foo </=><!->bar</!-><!+>beer</!+><=>\n</=><=>baz</=>"
    assert_equal(expected, docdiff.run(doc1, doc2, {:resolution => "word", :format => "user", :digest => false}))
  end
  def test_run_char_user()
    doc1 = Document.new("foo bar\nbaz", 'US-ASCII', 'LF')
    doc2 = Document.new("foo beer\nbaz", 'US-ASCII', 'LF')
    config = {:tag_common_start          => '<=>',
              :tag_common_end            => '</=>',
              :tag_del_start             => '<->',
              :tag_del_end               => '</->',
              :tag_add_start             => '<+>',
              :tag_add_end               => '</+>',
              :tag_change_before_start   => '<!->',
              :tag_change_before_end     => '</!->',
              :tag_change_after_start    => '<!+>',
              :tag_change_after_end      => '</!+>'}
    docdiff = DocDiff.new
    docdiff.config.update(config)
    expected = "<=>foo </=><=>b</=><!->a</!-><!+>ee</!+><=>r</=><=>\n</=><=>baz</=>"
    assert_equal(expected, docdiff.run(doc1, doc2, {:resolution => "char", :format => "user", :digest => false}))
  end
  def test_cli()
    expected = "Hello, my name is [-Watanabe.-]{+matz.+}\n"
    cmd = "ruby -I lib bin/docdiff --wdiff" +
      " sample/01.en.ascii.lf sample/02.en.ascii.lf"
    actual = `#{cmd}`.scan(/^.*?$\n/m).first
    assert_equal(expected, actual)
  end

  def teardown()
    #
  end

end
