require 'rubyunit'
require 'docdiff'
require 'nkf'

class TestStringPlus < RUNIT::TestCase

  def setup()
    #@text_en = "Foo bar."
    #@text_ja_kanhira = 
  end

  # to_char tests.
  def test_to_char_en_ascii()
    string   = "foo bar"
    string.extend DocDiff::StringPlus
    string.lang = "English"
    string.enc = "ASCII"
    string.eol = "\n"
    expected = ['f','o','o',' ','b','a','r']
    assert_equal(expected, string.to_char)
  end
  def test_to_char_ja_eucjp()
    string   = "漢字かなカタカナ"
    string.extend DocDiff::StringPlus
    string.lang = "Japanese"
    string.enc = "EUC-JP"
    string.eol = "\n"
    expected = ['漢','字','か','な','カ','タ','カ','ナ']
    assert_equal(expected, string.to_char)
  end
  def test_to_char_ja_sjis()
    string = NKF.nkf('-s', "漢字かなカタカナ")
    string.extend DocDiff::StringPlus
    string.lang = "Japanese"
    string.enc = "Shift_JIS"
    string.eol = "\n"
    expected = ['漢','字','か','な','カ','タ','カ','ナ'].collect{|s|NKF.nkf('-s', s)}
    assert_equal(expected, string.to_char)
  end

#   def test_count_char_en_ascii_cr()
#   end
#   def test_count_char_en_ascii_lf()
#   end
#   def test_count_char_en_ascii_crlf()
#   end
##   def test_count_char_ja_eucjp_cr()
##   end
#   def test_count_char_ja_eucjp_lf()
#   end
##   def test_count_char_ja_eucjp_crlf()
##   end
#   def test_count_char_ja_sjis_cr()
#   end
##   def test_count_char_ja_sjis_lf()
##   end
#   def test_count_char_ja_sjis_crlf()
#   end

  # to_word tests.
  def test_to_word_en_ascii_lf()
    string   = "foo bar baz quux."
    string.extend DocDiff::StringPlus
    string.lang = "English"
    string.enc = "ASCII"
    string.eol = "\n"
    expected = ['foo ','bar ','baz ','quux','.']
    assert_equal(expected, string.to_word)
  end
  def test_to_word_en_ascii_lf_hyphen()
    string   = "Mr. Black, he\'s a high-school student."
    string.extend DocDiff::StringPlus
    string.lang = "English"
    string.enc = "ASCII"
    string.eol = "\n"
    expected = ["Mr. ","Black",", ","he\'s ","a ","high-school ","student","."]
    assert_equal(expected, string.to_word)
  end
  # EUC-JP encoding.  EoL is LF.
  def test_to_word_ja_eucjp_kanhira()
    string   = NKF.nkf('-e',"食べたり飲んだりした。")
    string.extend DocDiff::StringPlus
    string.lang = "Japanese"
    string.enc = "EUC-JP"
    string.eol = "\n"
    expected = ['食べたり','飲んだりした','。'].collect{|s|NKF.nkf('-e', s)}
    assert_equal(expected, string.to_word)
  end
  def test_to_word_ja_eucjp_macronhira()
    string   = NKF.nkf('-e',"るーるるる。")
    string.extend DocDiff::StringPlus
    string.lang = "Japanese"
    string.enc = "EUC-JP"
    string.eol = "\n"
    expected = ['るーるるる','。'].collect{|s|NKF.nkf('-e', s)}
    assert_equal(expected, string.to_word)
  end
  def test_to_word_ja_eucjp_macronkata_trail()
    string   = NKF.nkf('-e',"フーコーのギター。")
    string.extend DocDiff::StringPlus
    string.lang = "Japanese"
    string.enc = "EUC-JP"
    string.eol = "\n"
    expected = ['フーコーの','ギター','。'].collect{|s|NKF.nkf('-e', s)}
    assert_equal(expected, string.to_word)
  end
  def test_to_word_ja_eucjp_macronkata_between()
    string   = NKF.nkf('-e',"データをソート。")
    string.extend DocDiff::StringPlus
    string.lang = "Japanese"
    string.enc = "EUC-JP"
    string.eol = "\n"
    expected = ['データを','ソート','。'].collect{|s|NKF.nkf('-e', s)}
    assert_equal(expected, string.to_word)
  end
  def test_to_word_ja_eucjp_repeatkan()
    string   = NKF.nkf('-e',"人々、我々、其々")
    string.extend DocDiff::StringPlus
    string.lang = "Japanese"
    string.enc = "EUC-JP"
    string.eol = "\n"
    expected = ['人々','、','我々','、','其々'].collect{|s|NKF.nkf('-e', s)}
    assert_equal(expected, string.to_word)
  end
  def test_to_word_ja_eucjp_withlatin()
    string   = NKF.nkf('-e',"漢字以外に\"I\'m a high-school student.\"のような欧文も含む文。")
    string.extend DocDiff::StringPlus
    string.lang = "Japanese"
    string.enc = "EUC-JP"
    string.eol = "\n"
    expected = ['漢字以外に','"','I\'m ','a ','high-school ','student','.','"','のような','欧文も','含む','文','。'].collect{|s|NKF.nkf('-e', s)}
    assert_equal(expected, string.to_word)
  end
  # Shift_JIS tests.  EoL is CRLF.
  def test_to_word_ja_sjis_kanhira()
    string   = NKF.nkf('-s',"食べたり飲んだりした。")
    string.extend DocDiff::StringPlus
    string.lang = "Japanese"
    string.enc = "Shift_JIS"
    string.eol = "\r\n"
    expected = ['食べたり','飲んだりした','。'].collect{|s|NKF.nkf('-s', s)}
    assert_equal(expected, string.to_word)
  end
  def test_to_word_ja_sjis_macronhira()
    string   = NKF.nkf('-s',"るーるるる。")
    string.extend DocDiff::StringPlus
    string.lang = "Japanese"
    string.enc = "Shift_JIS"
    string.eol = "\r\n"
    expected = ['るーるるる','。'].collect{|s|NKF.nkf('-s', s)}
    assert_equal(expected, string.to_word)
  end
  def test_to_word_ja_sjis_macronkata_trail()
    string   = NKF.nkf('-s',"フーコーのギター。")
    string.extend DocDiff::StringPlus
    string.lang = "Japanese"
    string.enc = "Shift_JIS"
    string.eol = "\r\n"
    expected = ['フーコーの','ギター','。'].collect{|s|NKF.nkf('-s', s)}
    assert_equal(expected, string.to_word)
  end
  def test_to_word_ja_sjis_macronkata_between()
    string   = NKF.nkf('-s',"データをソート。")
    string.extend DocDiff::StringPlus
    string.lang = "Japanese"
    string.enc = "Shift_JIS"
    string.eol = "\r\n"
    expected = ['データを','ソート','。'].collect{|s|NKF.nkf('-s', s)}
    assert_equal(expected, string.to_word)
  end
  def test_to_word_ja_sjis_repeatkan()
    string   = NKF.nkf('-s',"人々、我々、其々")
    string.extend DocDiff::StringPlus
    string.lang = "Japanese"
    string.enc = "Shift_JIS"
    string.eol = "\r\n"
    expected = ['人々','、','我々','、','其々'].collect{|s|NKF.nkf('-s', s)}
    assert_equal(expected, string.to_word)
  end
  def test_to_word_ja_sjis_withlatin()
    string   = NKF.nkf('-s',"漢字以外に\"I\'m a high-school student.\"のような欧文も含む文。")
    string.extend DocDiff::StringPlus
    string.lang = "Japanese"
    string.enc = "Shift_JIS"
    string.eol = "\r\n"
    expected = ['漢字以外に','"','I\'m ','a ','high-school ','student','.','"','のような','欧文も','含む','文','。'].collect{|s|NKF.nkf('-s', s)}
    assert_equal(expected, string.to_word)
  end

#   def test_count_word_en_ascii_cr()
#   end
#   def test_count_word_en_ascii_lf()
#   end
#   def test_count_word_en_ascii_crlf()
#   end
##   def test_count_word_ja_eucjp_cr()
##   end
#   def test_count_word_ja_eucjp_lf()
#   end
##   def test_count_word_ja_eucjp_crlf()
##   end
#   def test_count_word_ja_sjis_cr()
#   end
##   def test_count_word_ja_sjis_lf()
##   end
#   def test_count_word_ja_sjis_crlf()
#   end

  # to_line tests.
  def test_to_line_en_ascii_cr()
    string = "Foo bar.  \r\rBaz quux.\r"
    string.extend DocDiff::StringPlus
    string.lang = "English"
    string.enc = "ASCII"
    string.eol = "\r"
    expected = ["Foo bar.  \r","\r","Baz quux.\r"]
    assert_equal(expected, string.to_line)
  end
  def test_to_line_en_ascii_lf()
    string = "Foo bar.  \n\nBaz quux.\n"
    string.extend DocDiff::StringPlus
    string.lang = "English"
    string.enc = "ASCII"
    string.eol = "\n"
    expected = ["Foo bar.  \n","\n","Baz quux.\n"]
    assert_equal(expected, string.to_line)
  end
  def test_to_line_en_ascii_crlf()
    string = "Foo bar.  \r\n\r\nBaz quux.\r\n"
    string.extend DocDiff::StringPlus
    string.lang = "English"
    string.enc = "ASCII"
    string.eol = "\r\n"
    expected = ["Foo bar.  \r\n","\r\n","Baz quux.\r\n"]
    assert_equal(expected, string.to_line)
  end
  def test_to_line_ja_eucjp_lf()
    string = NKF.nkf('-e', "漢字\nかな\n\nカタカナ\n")
    string.extend DocDiff::StringPlus
    string.lang = "Japanese"
    string.enc = "EUC-JP"
    string.eol = "\n"
    expected = ["漢字\n","かな\n","\n","カタカナ\n"].collect{|s|NKF.nkf('-e', s)}
    assert_equal(expected, string.to_line)
  end
  def test_to_line_ja_sjis_cr()
    string = NKF.nkf('-s', "漢字\rかな\r\rカタカナ\r")
    string.extend DocDiff::StringPlus
    string.lang = "Japanese"
    string.enc = "Shift_JIS"
    string.eol = "\r"
    expected = ["漢字\r","かな\r","\r","カタカナ\r"].collect{|s|NKF.nkf('-s', s)}
    assert_equal(expected, string.to_line)
  end
  def test_to_line_ja_sjis_crlf()
    string = NKF.nkf('-s', "漢字\r\nかな\r\n\r\nカタカナ\r\n")
    string.extend DocDiff::StringPlus
    string.lang = "Japanese"
    string.enc = "Shift_JIS"
    string.eol = "\r\n"
    expected = ["漢字\r\n","かな\r\n","\r\n","カタカナ\r\n"].collect{|s|NKF.nkf('-s', s)}
    assert_equal(expected, string.to_line)
  end
  def test_count_line_en_ascii_cr()
    string = "Foo bar.  \r\rBaz quux.\r"
    string.extend DocDiff::StringPlus
    string.lang = "English"
    string.enc = "ASCII"
    string.eol = "\r"
    expected = 3
    assert_equal(expected, string.count_line)
  end
  def test_count_line_en_ascii_lf()
    string = "Foo bar.  \n\nBaz quux.\n"
    string.extend DocDiff::StringPlus
    string.lang = "English"
    string.enc = "ASCII"
    string.eol = "\n"
    expected = 3
    assert_equal(expected, string.count_line)
  end
  def test_count_line_en_ascii_crlf()
    string = "Foo bar.  \r\n\r\nBaz quux.\r\n"
    string.extend DocDiff::StringPlus
    string.lang = "English"
    string.enc = "ASCII"
    string.eol = "\r\n"
    expected = 3
    assert_equal(expected, string.count_line)
  end
  def test_count_line_ja_eucjp_lf()
    string = NKF.nkf('-e', "漢字\nかな\n\nカタカナ\n")
    string.extend DocDiff::StringPlus
    string.lang = "Japanese"
    string.enc = "EUC-JP"
    string.eol = "\n"
    expected = 4
    assert_equal(expected, string.count_line)
  end
  def test_count_line_ja_sjis_cr()
    string = NKF.nkf('-s', "漢字\rかな\r\rカタカナ\r")
    string.extend DocDiff::StringPlus
    string.lang = "Japanese"
    string.enc = "Shift_JIS"
    string.eol = "\r"
    expected = 4
    assert_equal(expected, string.count_line)
  end
  def test_count_line_ja_sjis_crlf()
    string = NKF.nkf('-s', "漢字\r\nかな\r\n\r\nカタカナ\r\n")
    string.extend DocDiff::StringPlus
    string.lang = "Japanese"
    string.enc = "Shift_JIS"
    string.eol = "\r\n"
    expected = 4
    assert_equal(expected, string.count_line)
  end

  # to_phrase
  # count_phrase
  # to_paragraph
  # count_paragraph

end
