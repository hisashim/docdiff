#!/usr/bin/ruby
require 'test/unit'
require 'docdiff/difference'
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

  def teardown()
    #
  end

end
