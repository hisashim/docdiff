require 'test/unit'
require 'jis0208'
require 'nkf'
require 'iconv'

class TC_JIS0208 < Test::Unit::TestCase
  def setup()
    #
  end

=begin obsolete
  def test_string_to_array()
    jis0208 = JIS0208.new
    expected = [0xe1, 0xa1, 0xa8] # "ɽ"(4129) UTF-8 as array
    # assert_equal(expected, Iconv.iconv("UTF-8", "EUC-JP", "ɽ").to_s)
    assert_equal(expected, jis0208.string_to_array("\xe1\xa1\xa8"))
  end
  def test_array_to_string()
    jis0208 = JIS0208.new
    expected = "\xe1\xa1\xa8" # "ɽ"(4129) in UTF-8 string
    # assert_equal(expected, Iconv.iconv("UTF-8", "EUC-JP", "ɽ").to_s)
    assert_equal(expected, jis0208.array_to_string([0xe1, 0xa1, 0xa8]))
  end
=end
=begin obsolete
  def test_to_value_array()
    expected = [0xe1, 0xa1, 0xa8] # "ɽ"(4129) UTF-8 as array
    assert_equal(expected, "\xe1\xa1\xa8".to_value_array)
  end
  def test_to_binary_string()
    expected = "\xe1\xa1\xa8" # "ɽ"(4129) in UTF-8 string
    assert_equal(expected, [0xe1, 0xa1, 0xa8].to_binary_string)
  end
  def teardown()
    #
  end
=end
end
