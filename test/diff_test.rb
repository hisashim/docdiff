#!/usr/bin/ruby
require 'test/unit'
require "docdiff/diff"

class TC_DocDiff_Diff < Test::Unit::TestCase
  Diff = DocDiff::Diff

  def setup()
    #
  end

  def test_new_ses()
    a1 = [:a, :b, :c]
    a2 = [:a, :x, :c]
    expected = [[:common_elt_elt, [:a], [:a]],
                [:del_elt,        [:b], nil],
                [:add_elt,         nil, [:x]],
                [:common_elt_elt, [:c], [:c]]]
    actual              = []
    actual_speculative  = []
    actual_shortestpath = []
    actual_contours     = []
    Diff.new(a1, a2).ses               .each{|e| actual              << e}
    Diff.new(a1, a2).ses(:speculative ).each{|e| actual_speculative  << e}
    Diff.new(a1, a2).ses(:shortestpath).each{|e| actual_shortestpath << e}
    Diff.new(a1, a2).ses(:contours    ).each{|e| actual_contours     << e}
    assert_equal(expected, actual)
    assert_equal(expected, actual_speculative)
    assert_equal(expected, actual_shortestpath)
    assert_equal(expected, actual_contours)
  end

  def teardown()
    #
  end

end
