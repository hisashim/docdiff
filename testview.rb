#!/usr/bin/ruby
require 'test/unit'
require 'view'
require 'nkf'
require 'uconv'

class TC_View < Test::Unit::TestCase

  def setup()
    #
  end

  def test_to_terminal_del_add()
    array1 = ['a', 'b', 'c']
    array2 = ['b', 'c', 'c']
    difference = Difference.new(array1, array2)
    expected =   ["\033[#{4}m\033[#{41}ma\033[0m",
                  "b",
                  "\033[#{1}m\033[#{44}mc\033[0m",
                  "c"]
    assert_equal(expected, View.new(difference, "ASCII", nil).to_terminal)
  end
  def test_to_terminal_change()
    array1 = ['a', 'b', 'c']
    array2 = ['a', 'x', 'c']
    difference = Difference.new(array1, array2)
    expected =   ["a",
                  "\033[#{4}m\033[#{43}mb\033[0m\033[#{1}m\033[#{42}mx\033[0m",
                  "c"]
    assert_equal(expected, View.new(difference, "ASCII", nil).to_terminal)
  end
  def test_to_html_del_add()
    array1 = ['a', 'b', 'c']
    array2 = ['b', 'c', 'c']
    difference = Difference.new(array1, array2)
    expected =   ['<span class="del"><del>a</del></span>',
                  '<span class="common">b</span>',
                  '<span class="add"><ins>c</ins></span>',
                  '<span class="common">c</span>']
    assert_equal(expected, View.new(difference, "ASCII", nil).to_html)
  end
  def test_to_html_change()
    array1 = ['a', 'b', 'c']
    array2 = ['a', 'x', 'c']
    difference = Difference.new(array1, array2)
    expected =   ['<span class="common">a</span>',
                  '<span class="before_change"><del>b</del></span><span class="after_change"><ins>x</ins></span>',
                  '<span class="common">c</span>']
    assert_equal(expected, View.new(difference, "ASCII", nil).to_html)
  end
  def test_to_xhtml_del_add()
    array1 = ['a', 'b', 'c']
    array2 = ['b', 'c', 'c']
    difference = Difference.new(array1, array2)
    expected =   ['<span class="del"><del>a</del></span>',
                  '<span class="common">b</span>',
                  '<span class="add"><ins>c</ins></span>',
                  '<span class="common">c</span>']
    assert_equal(expected, View.new(difference, "ASCII", nil).to_xhtml)
  end
  def test_to_xhtml_change()
    array1 = ['a', 'b', 'c']
    array2 = ['a', 'x', 'c']
    difference = Difference.new(array1, array2)
    expected =   ['<span class="common">a</span>',
                  '<span class="before_change"><del>b</del></span><span class="after_change"><ins>x</ins></span>',
                  '<span class="common">c</span>']
    assert_equal(expected, View.new(difference, "ASCII", nil).to_xhtml)
  end
  def test_to_manued_del_add()
    array1 = ['a', 'b', 'c']
    array2 = ['b', 'c', 'c']
    difference = Difference.new(array1, array2)
    expected =   ['[a/]',
                  'b',
                  '[/c]',
                  'c']
    assert_equal(expected, View.new(difference, "ASCII", nil).to_manued)
  end
  def test_to_manued_change()
    array1 = ['a', 'b', 'c']
    array2 = ['a', 'x', 'c']
    difference = Difference.new(array1, array2)
    expected =   ['a',
                  '[b/x]',
                  'c']
    assert_equal(expected, View.new(difference, "ASCII", nil).to_manued)
  end
  def test_to_wdiff_del_add()
    array1 = ['a', 'b', 'c']
    array2 = ['b', 'c', 'c']
    difference = Difference.new(array1, array2)
    expected =   ['[-a-]',
                  'b',
                  '{+c+}',
                  'c']
    assert_equal(expected, View.new(difference, "ASCII", nil).to_wdiff)
  end
  def test_to_wdiff_change()
    array1 = ['a', 'b', 'c']
    array2 = ['a', 'x', 'c']
    difference = Difference.new(array1, array2)
    expected =   ['a',
                  '[-b-]{+x+}',
                  'c']
    assert_equal(expected, View.new(difference, "ASCII", nil).to_wdiff)
  end

  def teardown()
    #
  end

end
