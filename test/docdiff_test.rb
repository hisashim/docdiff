#!/usr/bin/ruby
# -*- coding: us-ascii; -*-

# frozen_string_literal: false

require "test/unit"
require "docdiff"
require "nkf"

class TC_DocDiff < Test::Unit::TestCase
  Document = DocDiff::Document

  def setup
    #
  end

  def test_compare_by_line
    doc1 = Document.new("Foo bar.\nBaz quux.", "US-ASCII", "LF")
    doc2 = Document.new("Foo.\nBaz quux.", "US-ASCII", "LF")
    docdiff = DocDiff.new
    expected = [[:change_elt,     ["Foo bar.\n"], ["Foo.\n"]],
                [:common_elt_elt, ["Baz quux."], ["Baz quux."]]]
    assert_equal(expected, docdiff.compare_by_line(doc1, doc2))
  end

  def test_compare_by_line_word
    doc1 = Document.new("a b c d\ne f", "US-ASCII", "LF")
    doc2 = Document.new("a x c d\ne f", "US-ASCII", "LF")
    docdiff = DocDiff.new
    expected = [[:common_elt_elt, ["a "], ["a "]],
                [:change_elt,     ["b "], ["x "]],
                [:common_elt_elt, ["c ", "d", "\n"], ["c ", "d", "\n"]],
                [:common_elt_elt, ["e f"], ["e f"]]]
    assert_equal(expected, docdiff.compare_by_line_word(doc1, doc2))
  end

  def test_compare_by_line_word_char
    doc1 = Document.new("foo bar\nbaz", "US-ASCII", "LF")
    doc2 = Document.new("foo beer\nbaz", "US-ASCII", "LF")
    docdiff = DocDiff.new
    expected = [[:common_elt_elt, ["foo "], ["foo "]],
                [:common_elt_elt, ["b"], ["b"]],
                [:change_elt,     ["a"], ["e", "e"]],
                [:common_elt_elt, ["r"], ["r"]],
                [:common_elt_elt, ["\n"], ["\n"]],
                [:common_elt_elt, ["baz"], ["baz"]]]
    assert_equal(expected, docdiff.compare_by_line_word_char(doc1, doc2))
  end

  def test_run_line_html
    doc1 = Document.new("foo bar\nbaz", "US-ASCII", "LF")
    doc2 = Document.new("foo beer\nbaz", "US-ASCII", "LF")
    docdiff = DocDiff.new
    expected = <<~EOS
      <?xml version="1.0" encoding="US-ASCII"?>
      <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
      "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
      <html><head>
      <meta http-equiv="Content-Type" content="text/html; charset=US-ASCII" />
      <title>Difference</title>
      <style type="text/css">
       body {font-family: monospace;}
       span.del {background: hotpink; border: thin inset;}
       span.add {background: deepskyblue; font-weight: bolder; border: thin outset;}
       span.before-change {background: yellow; border: thin inset;}
       span.after-change {background: lime; font-weight: bolder; border: thin outset;}
       li.entry .position {font-weight: bolder; margin-top: 0em; margin-bottom: 0em; padding-top: 0.5em; padding-bottom: 0em;}
       li.entry .body {margin-top: 0em; margin-bottom: 0em; padding-top: 0em; padding-bottom: 0.5em;}
       li.entry {border-top: thin solid gray;}
      </style>
      </head><body><div>
      <span class="before-change"><del>foo bar<br />
      </del></span><span class="after-change"><ins>foo beer<br />
      </ins></span><span class="common">baz</span>
      </div></body></html>
    EOS
    assert_equal(expected, docdiff.run(doc1, doc2, {:resolution => "line", :format => "html", :digest => false}))
  end

  def test_run_line_manued
    doc1 = Document.new("foo bar\nbaz", "US-ASCII", "LF")
    doc2 = Document.new("foo beer\nbaz", "US-ASCII", "LF")
    docdiff = DocDiff.new
    expected = <<~EOS.chomp
      defparentheses [ ]
      defdelete      /
      defswap        |
      defcomment     ;
      defescape      ~
      deforder       newer-last
      defversion     0.9.5
      [foo bar
      /foo beer
      ]baz
    EOS
    assert_equal(expected, docdiff.run(doc1, doc2, {:resolution => "line", :format => "manued", :digest => false}))
  end

  def test_run_word_manued
    doc1 = Document.new("foo bar\nbaz", "US-ASCII", "LF")
    doc2 = Document.new("foo beer\nbaz", "US-ASCII", "LF")
    docdiff = DocDiff.new
    expected = <<~EOS.chomp
      defparentheses [ ]
      defdelete      /
      defswap        |
      defcomment     ;
      defescape      ~
      deforder       newer-last
      defversion     0.9.5
      foo [bar/beer]
      baz
    EOS
    assert_equal(expected, docdiff.run(doc1, doc2, {:resolution => "word", :format => "manued", :digest => false}))
  end

  def test_run_char_manued
    doc1 = Document.new("foo bar\nbaz", "US-ASCII", "LF")
    doc2 = Document.new("foo beer\nbaz", "US-ASCII", "LF")
    docdiff = DocDiff.new
    expected = <<~EOS.chomp
      defparentheses [ ]
      defdelete      /
      defswap        |
      defcomment     ;
      defescape      ~
      deforder       newer-last
      defversion     0.9.5
      foo b[a/ee]r
      baz
    EOS
    assert_equal(expected, docdiff.run(doc1, doc2, {:resolution => "char", :format => "manued", :digest => false}))
  end

  def test_run_line_user
    doc1 = Document.new("foo bar\nbaz", "US-ASCII", "LF")
    doc2 = Document.new("foo beer\nbaz", "US-ASCII", "LF")
    config = {:tag_common_start          => "<=>",
              :tag_common_end            => "</=>",
              :tag_del_start             => "<->",
              :tag_del_end               => "</->",
              :tag_add_start             => "<+>",
              :tag_add_end               => "</+>",
              :tag_change_before_start   => "<!->",
              :tag_change_before_end     => "</!->",
              :tag_change_after_start    => "<!+>",
              :tag_change_after_end      => "</!+>"}
    docdiff = DocDiff.new
    docdiff.config.update(config)
    expected = "<!->foo bar\n</!-><!+>foo beer\n</!+><=>baz</=>"
    assert_equal(expected, docdiff.run(doc1, doc2, {:resolution => "line", :format => "user", :digest => false}))
  end

  def test_run_word_user
    doc1 = Document.new("foo bar\nbaz", "US-ASCII", "LF")
    doc2 = Document.new("foo beer\nbaz", "US-ASCII", "LF")
    config = {:tag_common_start          => "<=>",
              :tag_common_end            => "</=>",
              :tag_del_start             => "<->",
              :tag_del_end               => "</->",
              :tag_add_start             => "<+>",
              :tag_add_end               => "</+>",
              :tag_change_before_start   => "<!->",
              :tag_change_before_end     => "</!->",
              :tag_change_after_start    => "<!+>",
              :tag_change_after_end      => "</!+>"}
    docdiff = DocDiff.new
    docdiff.config.update(config)
    expected = "<=>foo </=><!->bar</!-><!+>beer</!+><=>\n</=><=>baz</=>"
    assert_equal(expected, docdiff.run(doc1, doc2, {:resolution => "word", :format => "user", :digest => false}))
  end

  def test_run_char_user
    doc1 = Document.new("foo bar\nbaz", "US-ASCII", "LF")
    doc2 = Document.new("foo beer\nbaz", "US-ASCII", "LF")
    config = {:tag_common_start          => "<=>",
              :tag_common_end            => "</=>",
              :tag_del_start             => "<->",
              :tag_del_end               => "</->",
              :tag_add_start             => "<+>",
              :tag_add_end               => "</+>",
              :tag_change_before_start   => "<!->",
              :tag_change_before_end     => "</!->",
              :tag_change_after_start    => "<!+>",
              :tag_change_after_end      => "</!+>"}
    docdiff = DocDiff.new
    docdiff.config.update(config)
    expected = "<=>foo </=><=>b</=><!->a</!-><!+>ee</!+><=>r</=><=>\n</=><=>baz</=>"
    assert_equal(expected, docdiff.run(doc1, doc2, {:resolution => "char", :format => "user", :digest => false}))
  end

  def teardown
    #
  end
end
