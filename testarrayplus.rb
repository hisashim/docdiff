require 'rubyunit'
require 'arrayplus'

class TestArrayPlus < RUNIT::TestCase

  def setup
    @seed = 12
    srand @seed
    @n = 10
    @array = (1..@n).to_a.collect{
      (@n * (rand - 0.5)).to_i
    }.extend ArrayPlus
  end

  def test_freq
    expected = {0=>2, -2=>1, -1=>2, 1=>2, 3=>1, 4=>1, -3=>1}
    assert_equal(expected, @array.freq)
    expected = 1
    assert_equal(expected, @array.freq(3))
    expected = {0=>2, -2=>1, -1=>2, 1=>2, -3=>1}
    assert_equal(expected, @array.freq{|e|e<3})
  end

  def test_count
    expected = 10
    assert_equal(expected, @array.count)
    expected = 1
    assert_equal(expected, @array.count(3))
    expected = 5
    assert_equal(expected, @array.count{|e|e<3})
  end

  def test_pick_indice
    expected = (0..(@n - 1)).to_a
    assert_equal(expected, @array.pick_indice)
    expected = [7]
    assert_equal(expected, @array.pick_indice(3))
    expected = [0, 1, 3, 4, 5, 6, 8, 9]
    assert_equal(expected, @array.pick_indice{|e|e<3})
  end

end
