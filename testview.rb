#!/usr/bin/ruby
require 'test/unit'
require 'docdiff/view'
require 'docdiff/difference'
require 'nkf'
require 'uconv'

class TC_View < Test::Unit::TestCase

  def setup()
    #
  end

  def test_scan_lines_cr()
    str = "A\r\rA\n\nA\r\n\r\nA\n\r\n\rA"
    expected =   ["A\r", "\r", "A\n\nA\r", "\n\r", "\nA\n\r", "\n\r", "A"]
    actual = str.scan_lines("CR")
    assert_equal(expected, actual)
  end
  def test_scan_lines_lf()
    str = "A\r\rA\n\nA\r\n\r\nA\n\r\n\rA"
    expected =   ["A\r\rA\n", "\n", "A\r\n", "\r\n", "A\n", "\r\n", "\rA"]
    actual = str.scan_lines("LF")
    assert_equal(expected, actual)
  end
  def test_scan_lines_crlf()
    str = "A\r\rA\n\nA\r\n\r\nA\n\r\n\rA"
    expected = ["A\r\rA\n\nA\r\n", "\r\n", "A\n\r\n", "\rA"]
    actual = str.scan_lines("CRLF")
    assert_equal(expected, actual)
  end

  def test_source_lines_cr()
    array1 = "A\r\rA\n\nA\r\n\r\nA\n\r\n\rA".split(//)
    array2 = ["b", "c", "c"]
    difference = Difference.new(array1, array2)
    expected =   ["A\r", "\r", "A\n\nA\r", "\n\r", "\nA\n\r", "\n\r", "A"]
    actual = View.new(difference, "ASCII", "CR").source_lines
    assert_equal(expected, actual)
  end
  def test_source_lines_cr2()
    array1 = "A\r\rA\n\nA\r\n\r\nA\n\r\n\r".split(//)
    array2 = ["b", "c", "c"]
    difference = Difference.new(array1, array2)
    expected =   ["A\r", "\r", "A\n\nA\r", "\n\r", "\nA\n\r", "\n\r"]
    actual = View.new(difference, "ASCII", "CR").source_lines
    assert_equal(expected, actual)
  end
  def test_source_lines_lf()
    array1 = "A\r\rA\n\nA\r\n\r\nA\n\r\n\rA".split(//)
    array2 = ["b", "c", "c"]
    difference = Difference.new(array1, array2)
    expected =   ["A\r\rA\n", "\n", "A\r\n", "\r\n", "A\n", "\r\n", "\rA"]
    actual = View.new(difference, "ASCII", "LF").source_lines
    assert_equal(expected, actual)
  end
  def test_source_lines_lf2()
    array1 = "A\r\rA\n\nA\r\n\r\nA\n\r\n\r".split(//)
    array2 = ["b", "c", "c"]
    difference = Difference.new(array1, array2)
    expected =   ["A\r\rA\n", "\n", "A\r\n", "\r\n", "A\n", "\r\n", "\r"]
    actual = View.new(difference, "ASCII", "LF").source_lines
    assert_equal(expected, actual)
  end
  def test_source_lines_crlf()
    array1 = "A\r\rA\n\nA\r\n\r\nA\n\r\n\rA".split(//)
    array2 = ["b", "c", "c"]
    difference = Difference.new(array1, array2)
    expected =   ["A\r\rA\n\nA\r\n", "\r\n", "A\n\r\n", "\rA"]
    actual = View.new(difference, "ASCII", "CRLF").source_lines
    assert_equal(expected, actual)
  end
  def test_source_lines_crlf2()
    array1 = "A\r\rA\n\nA\r\n\r\nA\n\r\n\r".split(//)
    array2 = ["b", "c", "c"]
    difference = Difference.new(array1, array2)
    expected =   ["A\r\rA\n\nA\r\n", "\r\n", "A\n\r\n", "\r"]
    actual = View.new(difference, "ASCII", "CRLF").source_lines
    assert_equal(expected, actual)
  end
  def test_source_lines_noeol()
    array1 = ["a", "b", "c"]
    array2 = ["b", "c", "c"]
    difference = Difference.new(array1, array2)
    expected =   ["abc"]
    actual = View.new(difference, "ASCII", nil).source_lines
    assert_equal(expected, actual)
  end
  def test_target_lines_cr()
    array1 = ["a", "b", "\n", "c"]
    array2 = "A\r\rA\n\nA\r\n\r\nA\n\r\n\rA".split(//)
    difference = Difference.new(array1, array2)
    expected =   ["A\r", "\r", "A\n\nA\r", "\n\r", "\nA\n\r", "\n\r", "A"]
    actual = View.new(difference, "ASCII", "CR").target_lines
    assert_equal(expected, actual)
  end
  def test_target_lines_cr2()
    array1 = ["a", "b", "\n", "c"]
    array2 = "A\r\rA\n\nA\r\n\r\nA\n\r\n\r".split(//)
    difference = Difference.new(array1, array2)
    expected =   ["A\r", "\r", "A\n\nA\r", "\n\r", "\nA\n\r", "\n\r"]
    actual = View.new(difference, "ASCII", "CR").target_lines
    assert_equal(expected, actual)
  end
  def test_target_lines_lf()
    array1 = ["a", "b", "\n", "c"]
    array2 = "A\r\rA\n\nA\r\n\r\nA\n\r\n\rA".split(//)
    difference = Difference.new(array1, array2)
    expected =   ["A\r\rA\n", "\n", "A\r\n", "\r\n", "A\n", "\r\n", "\rA"]
    actual = View.new(difference, "ASCII", "LF").target_lines
    assert_equal(expected, actual)
  end
  def test_target_lines_lf2()
    array1 = ["a", "b", "\n", "c"]
    array2 = "A\r\rA\n\nA\r\n\r\nA\n\r\n\r".split(//)
    difference = Difference.new(array1, array2)
    expected =   ["A\r\rA\n", "\n", "A\r\n", "\r\n", "A\n", "\r\n", "\r"]
    actual = View.new(difference, "ASCII", "LF").target_lines
    assert_equal(expected, actual)
  end
  def test_target_lines_crlf()
    array1 = ["a", "b", "\n", "c"]
    array2 = "A\r\rA\n\nA\r\n\r\nA\n\r\n\rA".split(//)
    difference = Difference.new(array1, array2)
    expected = ["A\r\rA\n\nA\r\n", "\r\n", "A\n\r\n", "\rA"]
    actual = View.new(difference, "ASCII", "CRLF").target_lines
    assert_equal(expected, actual)
  end
  def test_target_lines_crlf2()
    array1 = ["a", "b", "\n", "c"]
    array2 = "A\r\rA\n\nA\r\n\r\nA\n\r\n\r".split(//)
    difference = Difference.new(array1, array2)
    expected = ["A\r\rA\n\nA\r\n", "\r\n", "A\n\r\n", "\r"]
    actual = View.new(difference, "ASCII", "CRLF").target_lines
    assert_equal(expected, actual)
  end
  def test_target_lines_noeol()
    array1 = ["a", "b", "c"]
    array2 = ["b", "c", "c"]
    difference = Difference.new(array1, array2)
    expected =   ["bcc"]
    actual = View.new(difference, "ASCII", nil).target_lines
    assert_equal(expected, actual)
  end

  def test_to_tty_del_add_ascii()
    array1 = ['a', 'b', 'c']
    array2 = ['b', 'c', 'c']
    difference = Difference.new(array1, array2)
    expected =   ["\033[#{4}m\033[#{41}ma\033[0m",
                  "b",
                  "\033[#{1}m\033[#{44}mc\033[0m",
                  "c"]
    assert_equal(expected, View.new(difference, "ASCII", nil).to_tty(nil, false))
  end
  def test_to_tty_change_ascii()
    array1 = ['a', 'b', 'c']
    array2 = ['a', 'x', 'c']
    difference = Difference.new(array1, array2)
    expected =   ["a",
                  "\033[#{4}m\033[#{43}mb\033[0m\033[#{1}m\033[#{42}mx\033[0m",
                  "c"]
    assert_equal(expected, View.new(difference, "ASCII", nil).to_tty(nil, false))
  end
  def test_to_tty_del_add_ja()
    array1 = ['あ', 'い', 'う']
    array2 = ['い', 'う', 'う']
    expected =   ["\033[#{4}m\033[#{41}mあ\033[0m",
                  "い",
                  "\033[#{1}m\033[#{44}mう\033[0m",
                  "う"]
    assert_equal(expected, View.new(Difference.new(array1, array2), "EUC-JP", nil).to_tty(nil, false))
    assert_equal(expected.collect{|i|NKF.nkf("-s",i)},
                 View.new(Difference.new(array1.collect{|i|NKF.nkf("-s",i)},
                                         array2.collect{|i|NKF.nkf("-s",i)}),
                          "Shift_JIS", nil).to_tty(nil, false))
    assert_equal(expected.collect{|i|Uconv.euctou8(i)},
                 View.new(Difference.new(array1.collect{|i|Uconv.euctou8(i)},
                                         array2.collect{|i|Uconv.euctou8(i)}),
                          "UTF-8", nil).to_tty(nil, false))
  end
  def test_to_tty_change_ja()
    array1 = ['あ', 'い', 'う']
    array2 = ['あ', '漢', 'う']
    expected =   ["あ",
                  "\033[#{4}m\033[#{43}mい\033[0m\033[#{1}m\033[#{42}m漢\033[0m",
                  "う"]
    assert_equal(expected, View.new(Difference.new(array1, array2), "EUC-JP", nil).to_tty(nil, false))
    assert_equal(expected.collect{|i|NKF.nkf("-s",i)},
                 View.new(Difference.new(array1.collect{|i|NKF.nkf("-s",i)},
                                         array2.collect{|i|NKF.nkf("-s",i)}),
                          "Shift_JIS", nil).to_tty(nil, false))
    assert_equal(expected.collect{|i|Uconv.euctou8(i)},
                 View.new(Difference.new(array1.collect{|i|Uconv.euctou8(i)},
                                         array2.collect{|i|Uconv.euctou8(i)}),
                          "UTF-8", nil).to_tty(nil, false))
  end
  def test_to_tty_digest()
    array1 = ["a", "\n", "b", "c", "d", "e", "\n", "f", "\n"]
    array2 = ["c", "d", "X", "\n", "Y", "e", "\n", "F", "\n"]
    expected =   ["1-2,(1) \033[#{4}m\033[#{41}ma\nb\033[0mcd\n",
                  "(2),1-2 cd\033[#{1}m\033[#{44}mX\nY\033[0me\n",
                  "3,3 e\033[#{4}m\033[#{43}mf\033[0m\033[#{1}m\033[#{42}mF\033[0m\n"]
    assert_equal(expected, View.new(Difference.new(array1, array2), "ASCII", "LF").to_tty_digest(nil, false))
  end


  def test_to_html_cr_ascii()
    array1 = ['a', "\r"]
    array2 = ['a', "\r"]
    difference = Difference.new(array1, array2)
    expected =   ["<span class=\"common\">a<br />\r</span>"]
    assert_equal(expected, View.new(difference, "ASCII", "CR").to_html(nil, false))
  end
  def test_to_html_lf_ascii()
    array1 = ['a', "\n"]
    array2 = ['a', "\n"]
    difference = Difference.new(array1, array2)
    expected =   ["<span class=\"common\">a<br />\n</span>"]
    assert_equal(expected, View.new(difference, "ASCII", "LF").to_html(nil, false))
  end
  def test_to_html_crlf_ascii()
    array1 = ['a', "\r\n"]
    array2 = ['a', "\r\n"]
    difference = Difference.new(array1, array2)
    expected =   ["<span class=\"common\">a<br />\r\n</span>"]
    assert_equal(expected, View.new(difference, "ASCII", "CRLF").to_html(nil, false))
  end
  def test_to_html_escaping_ascii()
    array1 = ['<>& ']
    array2 = ['<>& ']
    difference = Difference.new(array1, array2)
    expected =   ["<span class=\"common\">&lt;&gt;&amp;&nbsp;</span>"]
    assert_equal(expected, View.new(difference, "ASCII", nil).to_html(nil, false))
  end
  def test_to_html_digest()
    array1 = ["a", "\n", "b", "c", "d", "e", "\n", "f", "\n"]
    array2 = ["c", "d", "X", "\n", "Y", "e", "\n", "F", "\n"]
    expected =   ["<ul>",
                  "<li>1-2,(1)<br /><span class=\"del\"><del>a<br />\nb</del></span>cd</li>\n",
                  "<li>(2),1-2<br />cd<span class=\"add\"><ins>X<br />\nY</ins></span>e</li>\n",
                  "<li>3,3<br />e<span class=\"before_change\"><del>f</del></span><span class=\"after_change\"><ins>F</ins></span></li>\n",
                  "</ul>"]
    assert_equal(expected, View.new(Difference.new(array1, array2), "ASCII", "LF").to_html_digest(nil,false))
  end

  def test_to_html_del_add_ascii()
    array1 = ['a', 'b', 'c']
    array2 = ['b', 'c', 'c']
    difference = Difference.new(array1, array2)
    expected =   ['<span class="del"><del>a</del></span>',
                  '<span class="common">b</span>',
                  '<span class="add"><ins>c</ins></span>',
                  '<span class="common">c</span>']
    assert_equal(expected, View.new(difference, "ASCII", nil).to_html(nil, false))
  end
  def test_to_html_change_ascii()
    array1 = ['a', 'b', 'c']
    array2 = ['a', 'x', 'c']
    difference = Difference.new(array1, array2)
    expected =   ['<span class="common">a</span>',
                  '<span class="before_change"><del>b</del></span><span class="after_change"><ins>x</ins></span>',
                  '<span class="common">c</span>']
    assert_equal(expected, View.new(difference, "ASCII", nil).to_html(nil, false))
  end
  def test_to_html_del_add_ja()
    array1 = ['あ', 'い', 'う']
    array2 = ['い', 'う', 'う']
    expected =   ['<span class="del"><del>あ</del></span>',
                  '<span class="common">い</span>',
                  '<span class="add"><ins>う</ins></span>',
                  '<span class="common">う</span>']
    assert_equal(expected, View.new(Difference.new(array1, array2), "EUC-JP", nil).to_html(nil, false))
    assert_equal(expected.collect{|i|NKF.nkf("-s",i)},
                 View.new(Difference.new(array1.collect{|i|NKF.nkf("-s",i)},
                                         array2.collect{|i|NKF.nkf("-s",i)}),
                          "Shift_JIS", nil).to_html(nil, false))
    assert_equal(expected.collect{|i|Uconv.euctou8(i)},
                 View.new(Difference.new(array1.collect{|i|Uconv.euctou8(i)},
                                         array2.collect{|i|Uconv.euctou8(i)}),
                          "UTF-8", nil).to_html(nil, false))
  end
  def test_to_html_change_ja()
    array1 = ['あ', 'い', 'う']
    array2 = ['あ', '漢', 'う']
    expected =   ['<span class="common">あ</span>',
                  '<span class="before_change"><del>い</del></span><span class="after_change"><ins>漢</ins></span>',
                  '<span class="common">う</span>']
    assert_equal(expected, View.new(Difference.new(array1, array2), "EUC-JP", nil).to_html(nil, false))
    assert_equal(expected.collect{|i|NKF.nkf("-s",i)},
                 View.new(Difference.new(array1.collect{|i|NKF.nkf("-s",i)},
                                         array2.collect{|i|NKF.nkf("-s",i)}),
                          "Shift_JIS", nil).to_html(nil, false))
    assert_equal(expected.collect{|i|Uconv.euctou8(i)},
                 View.new(Difference.new(array1.collect{|i|Uconv.euctou8(i)},
                                         array2.collect{|i|Uconv.euctou8(i)}),
                          "UTF-8", nil).to_html(nil, false))
  end

  def test_to_manued_del_add_ascii()
    array1 = ['a', 'b', 'c']
    array2 = ['b', 'c', 'c']
    difference = Difference.new(array1, array2)
    expected =   ['[a/]',
                  'b',
                  '[/c]',
                  'c']
    assert_equal(expected, View.new(difference, "ASCII", nil).to_manued(nil, false))
  end
  def test_to_manued_change_ascii()
    array1 = ['a', 'b', 'c']
    array2 = ['a', 'x', 'c']
    difference = Difference.new(array1, array2)
    expected =   ['a',
                  '[b/x]',
                  'c']
    assert_equal(expected, View.new(difference, "ASCII", nil).to_manued(nil, false))
  end
  def test_to_manued_del_add_ja()
    array1 = ['あ', 'い', 'う']
    array2 = ['い', 'う', 'う']
    expected =   ['[あ/]',
                  'い',
                  '[/う]',
                  'う']
    assert_equal(expected, View.new(Difference.new(array1, array2), "EUC-JP", nil).to_manued(nil, false))
    assert_equal(expected.collect{|i|NKF.nkf("-s",i)},
                 View.new(Difference.new(array1.collect{|i|NKF.nkf("-s",i)},
                                         array2.collect{|i|NKF.nkf("-s",i)}),
                          "Shift_JIS", nil).to_manued(nil, false))
    assert_equal(expected.collect{|i|Uconv.euctou8(i)},
                 View.new(Difference.new(array1.collect{|i|Uconv.euctou8(i)},
                                         array2.collect{|i|Uconv.euctou8(i)}),
                          "UTF-8", nil).to_manued(nil, false))
  end
  def test_to_manued_change_ja()
    array1 = ['あ', 'い', 'う']
    array2 = ['あ', '漢', 'う']
    expected =   ['あ',
                  '[い/漢]',
                  'う']
    assert_equal(expected, View.new(Difference.new(array1, array2), "EUC-JP", nil).to_manued(nil, false))
    assert_equal(expected.collect{|i|NKF.nkf("-s",i)},
                 View.new(Difference.new(array1.collect{|i|NKF.nkf("-s",i)},
                                         array2.collect{|i|NKF.nkf("-s",i)}),
                          "Shift_JIS", nil).to_manued(nil, false))
    assert_equal(expected.collect{|i|Uconv.euctou8(i)},
                 View.new(Difference.new(array1.collect{|i|Uconv.euctou8(i)},
                                         array2.collect{|i|Uconv.euctou8(i)}),
                          "UTF-8", nil).to_manued(nil, false))
  end
  def test_to_manued_escaping_ascii()
    array1 = ['a', '[/;]~', 'b', '[/;]~']
    array2 = ['a', '[/;]~', 'b']
    difference = Difference.new(array1, array2)
    expected =   ["a~[/;]~~b", "[~[~/~;~]~~/]"]
    assert_equal(expected, View.new(difference, "ASCII", nil).to_manued(nil, false))
  end
  def test_to_manued_digest()
    array1 = ["a", "\n", "b", "c", "d", "e", "\n", "f", "\n"]
    array2 = ["c", "d", "X", "\n", "Y", "e", "\n", "F", "\n"]
    expected =   ["1-2,(1) [a\nb/]cd\n",
                  "(2),1-2 cd[/X\nY]e\n",
                  "3,3 e[f/F]\n"]
    assert_equal(expected, View.new(Difference.new(array1, array2), "ASCII", "LF").to_manued_digest(nil,false))
  end

  def test_to_wdiff_del_add_ascii()
    array1 = ['a', 'b', 'c']
    array2 = ['b', 'c', 'c']
    difference = Difference.new(array1, array2)
    expected =   ['[-a-]',
                  'b',
                  '{+c+}',
                  'c']
    assert_equal(expected, View.new(difference, "ASCII", nil).to_wdiff(nil, false))
  end
  def test_to_wdiff_change_ascii()
    array1 = ['a', 'b', 'c']
    array2 = ['a', 'x', 'c']
    difference = Difference.new(array1, array2)
    expected =   ['a',
                  '[-b-]{+x+}',
                  'c']
    assert_equal(expected, View.new(difference, "ASCII", nil).to_wdiff(nil, false))
  end
  def test_to_wdiff_del_add_ja()
    array1 = ['あ', 'い', 'う']
    array2 = ['い', 'う', 'う']
    expected =   ['[-あ-]',
                  'い',
                  '{+う+}',
                  'う']
    assert_equal(expected, View.new(Difference.new(array1, array2), "EUC-JP", nil).to_wdiff(nil, false))
    assert_equal(expected.collect{|i|NKF.nkf("-s",i)},
                 View.new(Difference.new(array1.collect{|i|NKF.nkf("-s",i)},
                                         array2.collect{|i|NKF.nkf("-s",i)}),
                          "Shift_JIS", nil).to_wdiff(nil, false))
    assert_equal(expected.collect{|i|Uconv.euctou8(i)},
                 View.new(Difference.new(array1.collect{|i|Uconv.euctou8(i)},
                                         array2.collect{|i|Uconv.euctou8(i)}),
                          "UTF-8", nil).to_wdiff(nil, false))
  end
  def test_to_wdiff_change_ja()
    array1 = ['あ', 'い', 'う']
    array2 = ['あ', '漢', 'う']
    expected =   ['あ',
                  '[-い-]{+漢+}',
                  'う']
    assert_equal(expected, View.new(Difference.new(array1, array2), "EUC-JP", nil).to_wdiff(nil, false))
    assert_equal(expected.collect{|i|NKF.nkf("-s",i)},
                 View.new(Difference.new(array1.collect{|i|NKF.nkf("-s",i)},
                                         array2.collect{|i|NKF.nkf("-s",i)}),
                          "Shift_JIS", nil).to_wdiff(nil, false))
    assert_equal(expected.collect{|i|Uconv.euctou8(i)},
                 View.new(Difference.new(array1.collect{|i|Uconv.euctou8(i)},
                                         array2.collect{|i|Uconv.euctou8(i)}),
                          "UTF-8", nil).to_wdiff(nil, false))
  end
  def test_to_wdiff_digest()
    array1 = ["a", "\n", "b", "c", "d", "e", "\n", "f", "\n"]
    array2 = ["c", "d", "X", "\n", "Y", "e", "\n", "F", "\n"]
    expected = ["1-2,(1) [-a\nb-]cd\n",
                "(2),1-2 cd{+X\nY+}e\n",
                "3,3 e[-f-]{+F+}\n"]
    assert_equal(expected, View.new(Difference.new(array1, array2), "ASCII", "LF").to_wdiff_digest(nil,false))
  end

  def test_to_user_del_add_en()
    array1 = ['a', 'b', 'c']
    array2 = ['b', 'c', 'c']
    difference = Difference.new(array1, array2)
    user_tags = {:start_common        => '<=>',
                 :end_common          => '</=>',
                 :start_del           => '<->',
                 :end_del             => '</->',
                 :start_add           => '<+>',
                 :end_add             => '</+>',
                 :start_before_change => '<!->',
                 :end_before_change   => '</!->',
                 :start_after_change  => '<!+>',
                 :end_after_change    => '</!+>'}
    expected =   ['<->a</->',
                  '<=>b</=>',
                  '<+>c</+>',
                  '<=>c</=>']
    assert_equal(expected, View.new(difference, "ASCII", nil).to_user(user_tags, false))
  end
  def test_to_user_change_en()
    array1 = ['a', 'b', 'c']
    array2 = ['a', 'x', 'c']
    difference = Difference.new(array1, array2)
    user_tags = {:start_common        => '<=>',
                 :end_common          => '</=>',
                 :start_del           => '<->',
                 :end_del             => '</->',
                 :start_add           => '<+>',
                 :end_add             => '</+>',
                 :start_before_change => '<!->',
                 :end_before_change   => '</!->',
                 :start_after_change  => '<!+>',
                 :end_after_change    => '</!+>'}
    expected =   ['<=>a</=>',
                  '<!->b</!-><!+>x</!+>',
                  '<=>c</=>']
    assert_equal(expected, View.new(difference, "ASCII", nil).to_user(user_tags, false))
  end
  def test_to_user_digest()
    array1 = ["a", "\n", "b", "c", "d", "e", "\n", "f", "\n"]
    array2 = ["c", "d", "X", "\n", "Y", "e", "\n", "F", "\n"]
    user_tags = {:start_common        => '<=>',
                 :end_common          => '</=>',
                 :start_del           => '<->',
                 :end_del             => '</->',
                 :start_add           => '<+>',
                 :end_add             => '</+>',
                 :start_before_change => '<!->',
                 :end_before_change   => '</!->',
                 :start_after_change  => '<!+>',
                 :end_after_change    => '</!+>'}
    expected = ["1-2,(1) <->a\nb</->cd\n",
                "(2),1-2 cd<+>X\nY</+>e\n",
                "3,3 e<!->f</!-><!+>F</!+>\n"]
    assert_equal(expected, View.new(Difference.new(array1, array2), "ASCII", "LF").to_user_digest(user_tags, false))
  end

  def teardown()
    #
  end

end
