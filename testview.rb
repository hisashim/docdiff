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

  def test_to_terminal_del_add_ascii()
    array1 = ['a', 'b', 'c']
    array2 = ['b', 'c', 'c']
    difference = Difference.new(array1, array2)
    expected =   ["\033[#{4}m\033[#{41}ma\033[0m",
                  "b",
                  "\033[#{1}m\033[#{44}mc\033[0m",
                  "c"]
    assert_equal(expected, View.new(difference, "ASCII", nil).to_terminal)
  end
  def test_to_terminal_change_ascii()
    array1 = ['a', 'b', 'c']
    array2 = ['a', 'x', 'c']
    difference = Difference.new(array1, array2)
    expected =   ["a",
                  "\033[#{4}m\033[#{43}mb\033[0m\033[#{1}m\033[#{42}mx\033[0m",
                  "c"]
    assert_equal(expected, View.new(difference, "ASCII", nil).to_terminal)
  end
  def test_to_terminal_del_add_ja()
    array1 = ['あ', 'い', 'う']
    array2 = ['い', 'う', 'う']
    expected =   ["\033[#{4}m\033[#{41}mあ\033[0m",
                  "い",
                  "\033[#{1}m\033[#{44}mう\033[0m",
                  "う"]
    assert_equal(expected, View.new(Difference.new(array1, array2), "EUC-JP", nil).to_terminal)
    assert_equal(expected.collect{|i|NKF.nkf("-s",i)},
                 View.new(Difference.new(array1.collect{|i|NKF.nkf("-s",i)},
                                         array2.collect{|i|NKF.nkf("-s",i)}),
                          "Shift_JIS", nil).to_terminal)
    assert_equal(expected.collect{|i|Uconv.euctou8(i)},
                 View.new(Difference.new(array1.collect{|i|Uconv.euctou8(i)},
                                         array2.collect{|i|Uconv.euctou8(i)}),
                          "UTF-8", nil).to_terminal)
  end
  def test_to_terminal_change_ja()
    array1 = ['あ', 'い', 'う']
    array2 = ['あ', '漢', 'う']
    expected =   ["あ",
                  "\033[#{4}m\033[#{43}mい\033[0m\033[#{1}m\033[#{42}m漢\033[0m",
                  "う"]
    assert_equal(expected, View.new(Difference.new(array1, array2), "EUC-JP", nil).to_terminal)
    assert_equal(expected.collect{|i|NKF.nkf("-s",i)},
                 View.new(Difference.new(array1.collect{|i|NKF.nkf("-s",i)},
                                         array2.collect{|i|NKF.nkf("-s",i)}),
                          "Shift_JIS", nil).to_terminal)
    assert_equal(expected.collect{|i|Uconv.euctou8(i)},
                 View.new(Difference.new(array1.collect{|i|Uconv.euctou8(i)},
                                         array2.collect{|i|Uconv.euctou8(i)}),
                          "UTF-8", nil).to_terminal)
  end

  def test_to_html_del_add_ascii()
    array1 = ['a', 'b', 'c']
    array2 = ['b', 'c', 'c']
    difference = Difference.new(array1, array2)
    expected =   ['<span class="del"><del>a</del></span>',
                  '<span class="common">b</span>',
                  '<span class="add"><ins>c</ins></span>',
                  '<span class="common">c</span>']
    assert_equal(expected, View.new(difference, "ASCII", nil).to_html)
  end
  def test_to_html_change_ascii()
    array1 = ['a', 'b', 'c']
    array2 = ['a', 'x', 'c']
    difference = Difference.new(array1, array2)
    expected =   ['<span class="common">a</span>',
                  '<span class="before_change"><del>b</del></span><span class="after_change"><ins>x</ins></span>',
                  '<span class="common">c</span>']
    assert_equal(expected, View.new(difference, "ASCII", nil).to_html)
  end
  def test_to_html_del_add_ja()
    array1 = ['あ', 'い', 'う']
    array2 = ['い', 'う', 'う']
    expected =   ['<span class="del"><del>あ</del></span>',
                  '<span class="common">い</span>',
                  '<span class="add"><ins>う</ins></span>',
                  '<span class="common">う</span>']
    assert_equal(expected, View.new(Difference.new(array1, array2), "EUC-JP", nil).to_html)
    assert_equal(expected.collect{|i|NKF.nkf("-s",i)},
                 View.new(Difference.new(array1.collect{|i|NKF.nkf("-s",i)},
                                         array2.collect{|i|NKF.nkf("-s",i)}),
                          "Shift_JIS", nil).to_html)
    assert_equal(expected.collect{|i|Uconv.euctou8(i)},
                 View.new(Difference.new(array1.collect{|i|Uconv.euctou8(i)},
                                         array2.collect{|i|Uconv.euctou8(i)}),
                          "UTF-8", nil).to_html)
  end
  def test_to_html_change_ja()
    array1 = ['あ', 'い', 'う']
    array2 = ['あ', '漢', 'う']
    expected =   ['<span class="common">あ</span>',
                  '<span class="before_change"><del>い</del></span><span class="after_change"><ins>漢</ins></span>',
                  '<span class="common">う</span>']
    assert_equal(expected, View.new(Difference.new(array1, array2), "EUC-JP", nil).to_html)
    assert_equal(expected.collect{|i|NKF.nkf("-s",i)},
                 View.new(Difference.new(array1.collect{|i|NKF.nkf("-s",i)},
                                         array2.collect{|i|NKF.nkf("-s",i)}),
                          "Shift_JIS", nil).to_html)
    assert_equal(expected.collect{|i|Uconv.euctou8(i)},
                 View.new(Difference.new(array1.collect{|i|Uconv.euctou8(i)},
                                         array2.collect{|i|Uconv.euctou8(i)}),
                          "UTF-8", nil).to_html)
  end

  def test_to_xhtml_del_add_ascii()
    array1 = ['a', 'b', 'c']
    array2 = ['b', 'c', 'c']
    difference = Difference.new(array1, array2)
    expected =   ['<span class="del"><del>a</del></span>',
                  '<span class="common">b</span>',
                  '<span class="add"><ins>c</ins></span>',
                  '<span class="common">c</span>']
    assert_equal(expected, View.new(difference, "ASCII", nil).to_xhtml)
  end
  def test_to_xhtml_change_ascii()
    array1 = ['a', 'b', 'c']
    array2 = ['a', 'x', 'c']
    difference = Difference.new(array1, array2)
    expected =   ['<span class="common">a</span>',
                  '<span class="before_change"><del>b</del></span><span class="after_change"><ins>x</ins></span>',
                  '<span class="common">c</span>']
    assert_equal(expected, View.new(difference, "ASCII", nil).to_xhtml)
  end
  def test_to_xhtml_del_add_ja()
    array1 = ['あ', 'い', 'う']
    array2 = ['い', 'う', 'う']
    expected =   ['<span class="del"><del>あ</del></span>',
                  '<span class="common">い</span>',
                  '<span class="add"><ins>う</ins></span>',
                  '<span class="common">う</span>']
    assert_equal(expected, View.new(Difference.new(array1, array2), "EUC-JP", nil).to_xhtml)
    assert_equal(expected.collect{|i|NKF.nkf("-s",i)},
                 View.new(Difference.new(array1.collect{|i|NKF.nkf("-s",i)},
                                         array2.collect{|i|NKF.nkf("-s",i)}),
                          "Shift_JIS", nil).to_xhtml)
    assert_equal(expected.collect{|i|Uconv.euctou8(i)},
                 View.new(Difference.new(array1.collect{|i|Uconv.euctou8(i)},
                                         array2.collect{|i|Uconv.euctou8(i)}),
                          "UTF-8", nil).to_xhtml)
  end
  def test_to_xhtml_change_ja()
    array1 = ['あ', 'い', 'う']
    array2 = ['あ', '漢', 'う']
    expected =   ['<span class="common">あ</span>',
                  '<span class="before_change"><del>い</del></span><span class="after_change"><ins>漢</ins></span>',
                  '<span class="common">う</span>']
    assert_equal(expected, View.new(Difference.new(array1, array2), "EUC-JP", nil).to_xhtml)
    assert_equal(expected.collect{|i|NKF.nkf("-s",i)},
                 View.new(Difference.new(array1.collect{|i|NKF.nkf("-s",i)},
                                         array2.collect{|i|NKF.nkf("-s",i)}),
                          "Shift_JIS", nil).to_xhtml)
    assert_equal(expected.collect{|i|Uconv.euctou8(i)},
                 View.new(Difference.new(array1.collect{|i|Uconv.euctou8(i)},
                                         array2.collect{|i|Uconv.euctou8(i)}),
                          "UTF-8", nil).to_xhtml)
  end

  def test_to_manued_del_add_ascii()
    array1 = ['a', 'b', 'c']
    array2 = ['b', 'c', 'c']
    difference = Difference.new(array1, array2)
    expected =   ['[a/]',
                  'b',
                  '[/c]',
                  'c']
    assert_equal(expected, View.new(difference, "ASCII", nil).to_manued)
  end
  def test_to_manued_change_ascii()
    array1 = ['a', 'b', 'c']
    array2 = ['a', 'x', 'c']
    difference = Difference.new(array1, array2)
    expected =   ['a',
                  '[b/x]',
                  'c']
    assert_equal(expected, View.new(difference, "ASCII", nil).to_manued)
  end
  def test_to_manued_del_add_ja()
    array1 = ['あ', 'い', 'う']
    array2 = ['い', 'う', 'う']
    expected =   ['[あ/]',
                  'い',
                  '[/う]',
                  'う']
    assert_equal(expected, View.new(Difference.new(array1, array2), "EUC-JP", nil).to_manued)
    assert_equal(expected.collect{|i|NKF.nkf("-s",i)},
                 View.new(Difference.new(array1.collect{|i|NKF.nkf("-s",i)},
                                         array2.collect{|i|NKF.nkf("-s",i)}),
                          "Shift_JIS", nil).to_manued)
    assert_equal(expected.collect{|i|Uconv.euctou8(i)},
                 View.new(Difference.new(array1.collect{|i|Uconv.euctou8(i)},
                                         array2.collect{|i|Uconv.euctou8(i)}),
                          "UTF-8", nil).to_manued)
  end
  def test_to_manued_change_ja()
    array1 = ['あ', 'い', 'う']
    array2 = ['あ', '漢', 'う']
    expected =   ['あ',
                  '[い/漢]',
                  'う']
    assert_equal(expected, View.new(Difference.new(array1, array2), "EUC-JP", nil).to_manued)
    assert_equal(expected.collect{|i|NKF.nkf("-s",i)},
                 View.new(Difference.new(array1.collect{|i|NKF.nkf("-s",i)},
                                         array2.collect{|i|NKF.nkf("-s",i)}),
                          "Shift_JIS", nil).to_manued)
    assert_equal(expected.collect{|i|Uconv.euctou8(i)},
                 View.new(Difference.new(array1.collect{|i|Uconv.euctou8(i)},
                                         array2.collect{|i|Uconv.euctou8(i)}),
                          "UTF-8", nil).to_manued)
  end

  def test_to_wdiff_del_add_ascii()
    array1 = ['a', 'b', 'c']
    array2 = ['b', 'c', 'c']
    difference = Difference.new(array1, array2)
    expected =   ['[-a-]',
                  'b',
                  '{+c+}',
                  'c']
    assert_equal(expected, View.new(difference, "ASCII", nil).to_wdiff)
  end
  def test_to_wdiff_change_ascii()
    array1 = ['a', 'b', 'c']
    array2 = ['a', 'x', 'c']
    difference = Difference.new(array1, array2)
    expected =   ['a',
                  '[-b-]{+x+}',
                  'c']
    assert_equal(expected, View.new(difference, "ASCII", nil).to_wdiff)
  end
  def test_to_wdiff_del_add_ja()
    array1 = ['あ', 'い', 'う']
    array2 = ['い', 'う', 'う']
    expected =   ['[-あ-]',
                  'い',
                  '{+う+}',
                  'う']
    assert_equal(expected, View.new(Difference.new(array1, array2), "EUC-JP", nil).to_wdiff)
    assert_equal(expected.collect{|i|NKF.nkf("-s",i)},
                 View.new(Difference.new(array1.collect{|i|NKF.nkf("-s",i)},
                                         array2.collect{|i|NKF.nkf("-s",i)}),
                          "Shift_JIS", nil).to_wdiff)
    assert_equal(expected.collect{|i|Uconv.euctou8(i)},
                 View.new(Difference.new(array1.collect{|i|Uconv.euctou8(i)},
                                         array2.collect{|i|Uconv.euctou8(i)}),
                          "UTF-8", nil).to_wdiff)
  end
  def test_to_wdiff_change_ja()
    array1 = ['あ', 'い', 'う']
    array2 = ['あ', '漢', 'う']
    expected =   ['あ',
                  '[-い-]{+漢+}',
                  'う']
    assert_equal(expected, View.new(Difference.new(array1, array2), "EUC-JP", nil).to_wdiff)
    assert_equal(expected.collect{|i|NKF.nkf("-s",i)},
                 View.new(Difference.new(array1.collect{|i|NKF.nkf("-s",i)},
                                         array2.collect{|i|NKF.nkf("-s",i)}),
                          "Shift_JIS", nil).to_wdiff)
    assert_equal(expected.collect{|i|Uconv.euctou8(i)},
                 View.new(Difference.new(array1.collect{|i|Uconv.euctou8(i)},
                                         array2.collect{|i|Uconv.euctou8(i)}),
                          "UTF-8", nil).to_wdiff)
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
    assert_equal(expected, View.new(difference, "ASCII", nil).to_user(user_tags))
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
    assert_equal(expected, View.new(difference, "ASCII", nil).to_user(user_tags))
  end

  def teardown()
    #
  end

end
