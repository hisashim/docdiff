#!/usr/bin/ruby
require 'test/unit'
require 'difference'
require 'nkf'
require 'uconv'

class TC_Difference < Test::Unit::TestCase

  def setup()
    #
  end

  def test_raw_list()
#     doc1 = Document.new("Foo bar.\nBaz quux.")
#     doc1.codeset = 'ASCII'
#     doc1.eol = 'LF'
#     doc2 = Document.new("Foo.\nBaz quux moo.")
#     doc2.codeset = 'ASCII'
#     doc2.eol = 'LF'
    array1 = [:a, :b, :c]
    array2 = [:a, :x, :c]
    expected =   [[:common_elt_elt, [:a], [:a]],
                  [:del_elt,        [:b], nil],
                  [:add_elt,         nil, [:x]],
                  [:common_elt_elt, [:c], [:c]]]
    assert_equal(expected, Difference.new(array1, array2).raw_list)
  end
  def test_new()
    array1 = [:a, :b, :c]
    array2 = [:a, :x, :c]
    expected =   [[:common_elt_elt, [:a], [:a]],
                  [:change_elt,     [:b], [:x]],
                  [:common_elt_elt, [:c], [:c]]]
    assert_equal(expected, Difference.new(array1, array2))
  end
  def test_to_terminal_del_add()
    array1 = ['a', 'b', 'c']
    array2 = ['b', 'c', 'c']
    expected =   ["\033[#{4}m\033[#{41}ma\033[0m",
                  "b",
                  "\033[#{1}m\033[#{44}mc\033[0m",
                  "c"]
    assert_equal(expected, Difference.new(array1, array2).to_terminal)
  end
  def test_to_terminal_change()
    array1 = ['a', 'b', 'c']
    array2 = ['a', 'x', 'c']
    expected =   ["a",
                  "\033[#{4}m\033[#{43}mb\033[0m\033[#{1}m\033[#{42}mx\033[0m",
                  "c"]
    assert_equal(expected, Difference.new(array1, array2).to_terminal)
  end
  def test_to_html_del_add()
    array1 = ['a', 'b', 'c']
    array2 = ['b', 'c', 'c']
    expected =   ['<span class="del"><del>a</del></span>',
                  '<span class="common">b</span>',
                  '<span class="add"><ins>c</ins></span>',
                  '<span class="common">c</span>']
    assert_equal(expected, Difference.new(array1, array2).to_html)
  end
  def test_to_html_change()
    array1 = ['a', 'b', 'c']
    array2 = ['a', 'x', 'c']
    expected =   ['<span class="common">a</span>',
                  '<span class="before_change"><del>b</del></span><span class="after_change"><ins>x</ins></span>',
                  '<span class="common">c</span>']
    assert_equal(expected, Difference.new(array1, array2).to_html)
  end
  def test_to_xhtml_del_add()
    array1 = ['a', 'b', 'c']
    array2 = ['b', 'c', 'c']
    expected =   ['<span class="del"><del>a</del></span>',
                  '<span class="common">b</span>',
                  '<span class="add"><ins>c</ins></span>',
                  '<span class="common">c</span>']
    assert_equal(expected, Difference.new(array1, array2).to_xhtml)
  end
  def test_to_xhtml_change()
    array1 = ['a', 'b', 'c']
    array2 = ['a', 'x', 'c']
    expected =   ['<span class="common">a</span>',
                  '<span class="before_change"><del>b</del></span><span class="after_change"><ins>x</ins></span>',
                  '<span class="common">c</span>']
    assert_equal(expected, Difference.new(array1, array2).to_xhtml)
  end
  def test_to_manued_del_add()
    array1 = ['a', 'b', 'c']
    array2 = ['b', 'c', 'c']
    expected =   ['[a/]',
                  'b',
                  '[/c]',
                  'c']
    assert_equal(expected, Difference.new(array1, array2).to_manued)
  end
  def test_to_manued_change()
    array1 = ['a', 'b', 'c']
    array2 = ['a', 'x', 'c']
    expected =   ['a',
                  '[b/x]',
                  'c']
    assert_equal(expected, Difference.new(array1, array2).to_manued)
  end

  def teardown()
    #
  end

end
