require 'rubyunit'
require 'arrayplus'

class TestArrayPlus < RUNIT::TestCase

  def setup()
    @seed = 12
    srand @seed
    @n = 10
    @array = (1..@n).to_a.collect{
      (@n * (rand - 0.5)).to_i
    }.extend ArrayPlus
  end

  def test_freq()
    expected = {0=>2, -2=>1, -1=>2, 1=>2, 3=>1, 4=>1, -3=>1}
    assert_equal(expected, @array.freq)
    expected = 1
    assert_equal(expected, @array.freq(3))
    expected = {0=>2, -2=>1, -1=>2, 1=>2, -3=>1}
    assert_equal(expected, @array.freq{|e|e<3})
  end

  def test_count()
    expected = 10
    assert_equal(expected, @array.count)
    expected = 1
    assert_equal(expected, @array.count(3))
    expected = 5
    assert_equal(expected, @array.count{|e|e<3})
  end

  def test_locate()
    expected = (0..(@n - 1)).to_a
    assert_equal(expected, @array.locate)
    expected = [7]
    assert_equal(expected, @array.locate(3))
    expected = [0, 1, 3, 4, 5, 6, 8, 9]
    assert_equal(expected, @array.locate{|e|e<3})
  end

  def test_flatten()
    a = [1,[2,[3,[4,[5]]]]].extend ArrayPlus
    expected = [1,2,3,4,5]
    assert_equal(expected, a.flatten)
    expected = [1,[2,[3,[4,[5]]]]]
    assert_equal(expected, a.flatten(-1))
    expected = [1,[2,[3,[4,[5]]]]]
    assert_equal(expected, a.flatten(0))
    expected = [1,2,[3,[4,[5]]]]
    assert_equal(expected, a.flatten(1))
    expected = [1,2,3,[4,[5]]]
    assert_equal(expected, a.flatten(2))
    expected = [1,2,3,4,[5]]
    assert_equal(expected, a.flatten(3))
    expected = [1,2,3,4,5]
    assert_equal(expected, a.flatten(4))
    expected = [1,2,3,4,5]
    assert_equal(expected, a.flatten(5))
    expected = [1,2,3,4,5]
    assert_equal(expected, a.flatten(6))
  end

  def test_subtract()
    expected = [3,1,3]
    a = [3,3,2,1,3].extend ArrayPlus
    assert_equal(expected, a.subtract([2,3]))
  end

  def test_longest()
    expected = "quux"
    a = ["foo","bar","quux"].extend ArrayPlus
    assert_equal(expected, a.longest)
    expected = -100
    a = [-100,100,0].extend ArrayPlus
    assert_equal(expected, a.longest)
  end

  def test_shortest()
    expected = "quux"
    a = [-10000,"foobar","quux"].extend ArrayPlus
    assert_equal(expected, a.shortest)
    expected = "bar"
    a = ["foo","bar","quux"].extend ArrayPlus
    assert_equal(expected, a.shortest)
  end

  def test_largest()
    expected = 10
    a = [-10000,0,10].extend ArrayPlus
    assert_equal(expected, a.largest)
    expected = "c"
    a = ["a","bb","c"].extend ArrayPlus
    assert_equal(expected, a.largest)
  end

  def test_smallest()
    expected = -100
    a = [-100,0,100].extend ArrayPlus
    assert_equal(expected, a.smallest)
    expected = 10
    a = [10,10.0,100].extend ArrayPlus
    assert_equal(expected, a.smallest)
  end

  def test_median()
    expected = 4
    a = [1,4,9,100,0].extend(ArrayPlus)
    assert_equal(expected, a.median)
    expected = 29.5
    a = [1,4,9,50,100,0].extend(ArrayPlus)
    assert_equal(expected, a.median)
    expected = 54.5
    a = [1,9,100,0].extend(ArrayPlus)
    assert_equal(expected, a.median)

  end

  def test_mode()
    expected = 3
    a = [1,3,3,3,2,2,0].extend ArrayPlus
    assert_equal(expected, a.mode)
    expected = 2
    a = [1,3,3,2,2,0].extend ArrayPlus
    assert_equal(expected, a.mode) # 2 or 3
  end

end
