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
    s      = "foo bar"
    s.extend DocDiff::StringPlus
    s.lang = "English"
    s.enc  = "ASCII"
    s.eol  = "\n"
    expected = ['f','o','o',' ','b','a','r']
    assert_equal(expected, s.to_char)
  end
  def test_to_char_ja_eucjp()
    s      = "漢字かなカタカナ"
    s.extend DocDiff::StringPlus
    s.lang = "Japanese"
    s.enc  = "EUC-JP"
    s.eol  = "\n"
    expected = ['漢','字','か','な','カ','タ','カ','ナ']
    assert_equal(expected, s.to_char)
  end
  def test_to_char_ja_sjis()
    s = NKF.nkf('-s', "漢字かなカタカナ")
    s.extend DocDiff::StringPlus
    s.lang = "Japanese"
    s.enc  = "Shift_JIS"
    s.eol  = "\n"
    expected = ['漢','字','か','な','カ','タ','カ','ナ'].collect{|st|
      NKF.nkf('-s', st)
    }
    assert_equal(expected, s.to_char)
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
    s   = "foo bar baz quux."
    s.extend DocDiff::StringPlus
    s.lang = "English"
    s.enc = "ASCII"
    s.eol = "\n"
    expected = ['foo ','bar ','baz ','quux','.']
    assert_equal(expected, s.to_word)
  end
  def test_to_word_en_ascii_lf_hyphen()
    s   = "Mr. Black, he\'s a high-school student."
    s.extend DocDiff::StringPlus
    s.lang = "English"
    s.enc = "ASCII"
    s.eol = "\n"
    expected = ["Mr. ","Black",", ","he\'s ","a ","high-school ","student","."]
    assert_equal(expected, s.to_word)
  end
  # EUC-JP encoding.  EoL is LF.
  def test_to_word_ja_eucjp_kanhira()
    s   = NKF.nkf('-e',"食べたり飲んだりした。")
    s.extend DocDiff::StringPlus
    s.lang = "Japanese"
    s.enc = "EUC-JP"
    s.eol = "\n"
    expected = ['食べたり','飲んだりした','。'].collect{|st|
      NKF.nkf('-e', st)
    }
    assert_equal(expected, s.to_word)
  end
  def test_to_word_ja_eucjp_macronhira()
    s   = NKF.nkf('-e',"るーるるる。")
    s.extend DocDiff::StringPlus
    s.lang = "Japanese"
    s.enc = "EUC-JP"
    s.eol = "\n"
    expected = ['るーるるる','。'].collect{|st|
      NKF.nkf('-e', st)
    }
    assert_equal(expected, s.to_word)
  end
  def test_to_word_ja_eucjp_macronkata_trail()
    s   = NKF.nkf('-e',"フーコーのギター。")
    s.extend DocDiff::StringPlus
    s.lang = "Japanese"
    s.enc = "EUC-JP"
    s.eol = "\n"
    expected = ['フーコーの','ギター','。'].collect{|st|
      NKF.nkf('-e', st)
    }
    assert_equal(expected, s.to_word)
  end
  def test_to_word_ja_eucjp_macronkata_between()
    s   = NKF.nkf('-e',"データをソート。")
    s.extend DocDiff::StringPlus
    s.lang = "Japanese"
    s.enc = "EUC-JP"
    s.eol = "\n"
    expected = ['データを','ソート','。'].collect{|st|
      NKF.nkf('-e', st)
    }
    assert_equal(expected, s.to_word)
  end
  def test_to_word_ja_eucjp_repeatkan()
    s   = NKF.nkf('-e',"人々、我々、其々")
    s.extend DocDiff::StringPlus
    s.lang = "Japanese"
    s.enc = "EUC-JP"
    s.eol = "\n"
    expected = ['人々','、','我々','、','其々'].collect{|st|
      NKF.nkf('-e', st)
    }
    assert_equal(expected, s.to_word)
  end
  def test_to_word_ja_eucjp_withlatin()
    s = NKF.nkf('-e',"漢字以外に\"I\'m a high-school student.\"のような欧文も含む文。")
    s.extend DocDiff::StringPlus
    s.lang = "Japanese"
    s.enc  = "EUC-JP"
    s.eol  = "\n"
    expected = ['漢字以外に','"','I\'m ','a ','high-school ','student','.','"',
                'のような','欧文も','含む','文','。'].collect{|st|
      NKF.nkf('-e', st)
    }
    assert_equal(expected, s.to_word)
  end
  # Shift_JIS tests.  EoL is CRLF.
  def test_to_word_ja_sjis_kanhira()
    s   = NKF.nkf('-s',"食べたり飲んだりした。")
    s.extend DocDiff::StringPlus
    s.lang = "Japanese"
    s.enc = "Shift_JIS"
    s.eol = "\r\n"
    expected = ['食べたり','飲んだりした','。'].collect{|st|
      NKF.nkf('-s', st)
    }
    assert_equal(expected, s.to_word)
  end
  def test_to_word_ja_sjis_macronhira()
    s   = NKF.nkf('-s',"るーるるる。")
    s.extend DocDiff::StringPlus
    s.lang = "Japanese"
    s.enc = "Shift_JIS"
    s.eol = "\r\n"
    expected = ['るーるるる','。'].collect{|st|
      NKF.nkf('-s', st)
    }
    assert_equal(expected, s.to_word)
  end
  def test_to_word_ja_sjis_macronkata_trail()
    s   = NKF.nkf('-s',"フーコーのギター。")
    s.extend DocDiff::StringPlus
    s.lang = "Japanese"
    s.enc = "Shift_JIS"
    s.eol = "\r\n"
    expected = ['フーコーの','ギター','。'].collect{|st|
      NKF.nkf('-s', st)
    }
    assert_equal(expected, s.to_word)
  end
  def test_to_word_ja_sjis_macronkata_between()
    s   = NKF.nkf('-s',"データをソート。")
    s.extend DocDiff::StringPlus
    s.lang = "Japanese"
    s.enc = "Shift_JIS"
    s.eol = "\r\n"
    expected = ['データを','ソート','。'].collect{|st|
      NKF.nkf('-s', st)
    }
    assert_equal(expected, s.to_word)
  end
  def test_to_word_ja_sjis_repeatkan()
    s   = NKF.nkf('-s',"人々、我々、其々")
    s.extend DocDiff::StringPlus
    s.lang = "Japanese"
    s.enc = "Shift_JIS"
    s.eol = "\r\n"
    expected = ['人々','、','我々','、','其々'].collect{|st|
      NKF.nkf('-s', st)
    }
    assert_equal(expected, s.to_word)
  end
  def test_to_word_ja_sjis_withlatin()
    s   = NKF.nkf('-s',"漢字以外に\"I\'m a high-school student.\"のような欧文も含む文。")
    s.extend DocDiff::StringPlus
    s.lang = "Japanese"
    s.enc = "Shift_JIS"
    s.eol = "\r\n"
    expected = ['漢字以外に','"','I\'m ','a ','high-school ','student','.','"',
                'のような','欧文も','含む','文','。'].collect{|st|
      NKF.nkf('-s', st)
    }
    assert_equal(expected, s.to_word)
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
    s = "Foo bar.  \r\rBaz quux.\r"
    s.extend DocDiff::StringPlus
    s.lang = "English"
    s.enc = "ASCII"
    s.eol = "\r"
    expected = ["Foo bar.  \r","\r","Baz quux.\r"]
    assert_equal(expected, s.to_line)
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
