#!/usr/bin/ruby
# Extracts multibyte characters from JIS0208.TXT.
# (ftp://ftp.unicode.org/Public/MAPPINGS/OBSOLETE/EASTASIA/JIS/JIS0208.TXT)
# 2003-03-03 .. 20xx-xx-xx, Hisashi MORITA.  Use freely at your own risk.
# Usage:   jis0208.rb <Ku> <Ten> <Codeset> #=> \xXX...
# Example: jis0208.rb 1 1 utf-8            #=> \xe3\x80\x80

class JIS0208
  def utf16_to_utf8(utf16)  # Convert UTF-16 to UTF-8N
    utf16value = (utf16.unpack("C*")[0] * 256 + utf16.unpack("C*")[1])
    if utf16value < 0x7f       # 1-byte utf-8
      utf8 = utf16value.to_a.pack("C*")
    elsif utf16value < 0x800   # 2-byte utf-8
      utf8 = [(0xC0 | (utf16value / 64)), 
              (0x80 | (utf16value % 64))].pack("C*")
    else                       # 3-byte utf-8
      utf8 = [(0xE0 | ((utf16value / 64) / 64)), 
              (0x80 | ((utf16value / 64) % 64)), 
              (0x80 | (utf16value % 64))].pack("C*")
    end
  end
  def initialize()
    @lines = File.readlines("JIS0208.TXT")
    @lines = @lines.grep(/^[^\#]/)  # remove comments
    @lines = @lines.collect{|l| l.sub(/\s+\#[^\#]+$/,'')} # remove unicode names
    @char_db = @lines.collect {|line|
      sjis, jis, utf16 = line.split.collect{|string|
        string.sub(/0x/, '').to_a.pack("H*")  # "0xXXXX" to 8-bit byte string
      }
      jis_byte_pair = jis.unpack("C*")
      # jis + 0x8080 => euc
      euc     = jis_byte_pair.collect {|byte| (byte + 0x80)}.pack("C*")
      # jis - 0x2020 => ku, ten
      ku, ten = jis_byte_pair.collect {|byte| (byte - 0x20)}
      utf8    = utf16_to_utf8(utf16)
      {:s=>sjis, :j=>jis, :u16=>utf16, :e=>euc, :u8=>utf8, :ku=>ku, :ten=>ten}
    }
    @characters = {}
    @char_db.each{|char|
      if @characters[char[:ku]].nil?
        @characters[char[:ku]] = {}
      end
      if @characters[char[:ku]][char[:ten]].nil?
        @characters[char[:ku]][char[:ten]] = {
          :s=>char[:s], 
          :j=>char[:j], 
          :u16=>char[:u16], 
          :e=>char[:e], 
          :u8=>char[:u8]
        }
      end
    }
  end
  attr_reader :char_db
  attr_reader :characters
  def char(ku, ten, codeset)
    case
    when /^[Ee]/ =~ codeset then codeset = :e
    when /^[Ss]/ =~ codeset then codeset = :s
    when /^[Jj]/ =~ codeset then codeset = :j
    when /^[Uu].*16$/ =~ codeset then codeset = :u16
    when /^[Uu].*8$/ =~ codeset then codeset = :u8
    else
      raise "invalid codeset name (#{codeset})\n"
    end
    characters[ku][ten][codeset].unpack('C*').collect{|byte|
      sprintf("\\x%x",byte)
    }.join
  end


end

if __FILE__ == $0

  # euc-jp
  def euc_ja_alnum()
    j = JIS0208.new
    r = []
    (3).to_a.each{|ku|(16..25).to_a.each{|ten|r << j.char(ku,ten,"e")}}
    (3).to_a.each{|ku|(33..58).to_a.each{|ten|r << j.char(ku,ten,"e")}}
    (3).to_a.each{|ku|(65..90).to_a.each{|ten|r << j.char(ku,ten,"e")}}
    r
  end
  def euc_ja_blank()
    j = JIS0208.new
    r = []
    (1).to_a.each{|ku|(1).to_a.each{|ten|r << j.char(ku,ten,"e")}}
    r
  end
  def euc_ja_print()
    euc_ja_graph() + euc_ja_blank()
  end
  def euc_ja_graph()
    euc_ja_alnum() + euc_ja_punct()
  end
  def euc_ja_punct()
    j = JIS0208.new
    r = []
    (1).to_a.each{|ku|( 2..94).to_a.each{|ten|r << j.char(ku,ten,"e")}}
    (2).to_a.each{|ku|( 1..14).to_a.each{|ten|r << j.char(ku,ten,"e")}}
    (2).to_a.each{|ku|(26..33).to_a.each{|ten|r << j.char(ku,ten,"e")}}
    (2).to_a.each{|ku|(42..48).to_a.each{|ten|r << j.char(ku,ten,"e")}}
    (2).to_a.each{|ku|(60..74).to_a.each{|ten|r << j.char(ku,ten,"e")}}
    (2).to_a.each{|ku|(82..89).to_a.each{|ten|r << j.char(ku,ten,"e")}}
    (2).to_a.each{|ku|(94    ).to_a.each{|ten|r << j.char(ku,ten,"e")}}
    (6).to_a.each{|ku|( 1..24).to_a.each{|ten|r << j.char(ku,ten,"e")}}
    (6).to_a.each{|ku|(33..56).to_a.each{|ten|r << j.char(ku,ten,"e")}}
    (7).to_a.each{|ku|( 1..33).to_a.each{|ten|r << j.char(ku,ten,"e")}}
    (7).to_a.each{|ku|(49..81).to_a.each{|ten|r << j.char(ku,ten,"e")}}
    (8).to_a.each{|ku|( 1..32).to_a.each{|ten|r << j.char(ku,ten,"e")}}
    r
  end
  def euc_ja_space()
    j = JIS0208.new
    r = []
    (1).to_a.each{|ku|(1).to_a.each{|ten|r << j.char(ku,ten,"e")}}
    r
  end
  def euc_hiragana()
    j = JIS0208.new
    r = []
    (4).to_a.each{|ku|(1..83).to_a.each{|ten|r << j.char(ku,ten,"e")}}
    r
  end
  def euc_katakana()
    j = JIS0208.new
    r = []
    (5).to_a.each{|ku|(1..86).to_a.each{|ten|r << j.char(ku,ten,"e")}}
    r
  end
  def euc_kanji()
    j = JIS0208.new
    r = []
    (16..46).to_a.each{|ku| r << "#{j.char(ku,1,'e')}-#{j.char(ku,94,'e')}"}
    (47).to_a.each{|ku|r << "#{j.char(ku,1,'e')}-#{j.char(ku,51,'e')}"}
    (48..83).to_a.each{|ku|r << "#{j.char(ku,1,'e')}-#{j.char(ku,94,'e')}"}
    (84).to_a.each{|ku|r << "#{j.char(ku,1,'e')}-#{j.char(ku,6,'e')}"}
    r
  end

  # sjis (cp932)
  def sjis_ja_alnum()
    j = JIS0208.new
    r = []
    (3).to_a.each{|ku|(16..25).to_a.each{|ten|r << j.char(ku,ten,"s")}}
    (3).to_a.each{|ku|(33..58).to_a.each{|ten|r << j.char(ku,ten,"s")}}
    (3).to_a.each{|ku|(65..90).to_a.each{|ten|r << j.char(ku,ten,"s")}}
    r
  end
  def sjis_ja_blank()
    j = JIS0208.new
    r = []
    (1).to_a.each{|ku|(1).to_a.each{|ten|r << j.char(ku,ten,"s")}}
    r
  end
  def sjis_ja_print()
    sjis_ja_graph() + sjis_ja_blank()
  end
  def sjis_ja_graph()
    sjis_ja_alnum() + sjis_ja_punct()
  end
  def sjis_ja_punct()
    j = JIS0208.new
    r = []
    (1).to_a.each{|ku|(2..94).to_a.each{|ten|r << j.char(ku,ten,"s")}}
    (2).to_a.each{|ku|(1..14).to_a.each{|ten|r << j.char(ku,ten,"s")}}
    (2).to_a.each{|ku|(26..33).to_a.each{|ten|r << j.char(ku,ten,"s")}}
    (2).to_a.each{|ku|(42..48).to_a.each{|ten|r << j.char(ku,ten,"s")}}
    (2).to_a.each{|ku|(60..74).to_a.each{|ten|r << j.char(ku,ten,"s")}}
    (2).to_a.each{|ku|(82..89).to_a.each{|ten|r << j.char(ku,ten,"s")}}
    (2).to_a.each{|ku|(94).to_a.each{|ten|r << j.char(ku,ten,"s")}}
    (6).to_a.each{|ku|(1..24).to_a.each{|ten|r << j.char(ku,ten,"s")}}
    (6).to_a.each{|ku|(33..56).to_a.each{|ten|r << j.char(ku,ten,"s")}}
    (7).to_a.each{|ku|(1..33).to_a.each{|ten|r << j.char(ku,ten,"s")}}
    (7).to_a.each{|ku|(49..81).to_a.each{|ten|r << j.char(ku,ten,"s")}}
    (8).to_a.each{|ku|(1..32).to_a.each{|ten|r << j.char(ku,ten,"s")}}
    #(13).to_a.each{|ku|(1..30).to_a.each{|ten|r << j.char(ku,ten,"s")}}#cp932
    #(13).to_a.each{|ku|(32..54).to_a.each{|ten|r << j.char(ku,ten,"s")}}#cp932
    #(13).to_a.each{|ku|(63..92).to_a.each{|ten|r << j.char(ku,ten,"s")}}#cp932
    #(92).to_a.each{|ku|(81..94).to_a.each{|ten|r << j.char(ku,ten,"s")}}#cp932
    r
  end
  def sjis_ja_space()
    j = JIS0208.new
    r = []
    (1).to_a.each{|ku|(1).to_a.each{|ten|r << j.char(ku,ten,"s")}}
    r
  end
  def sjis_hiragana()
    j = JIS0208.new
    r = []
    (4).to_a.each{|ku|(1..83).to_a.each{|ten|r << j.char(ku,ten,"s")}}
    r
  end
  def sjis_katakana()
    j = JIS0208.new
    r = []
    (5).to_a.each{|ku|(1..86).to_a.each{|ten|r << j.char(ku,ten,"s")}}
    r
  end
  def sjis_kanji()
    j = JIS0208.new
    r = []
    (16..46).to_a.each{|ku|r << "#{j.char(ku,1,'s')}-#{j.char(ku,94,'s')}"}
    (47).to_a.each{|ku|r << "#{j.char(ku,1,'s')}-#{j.char(ku,51,'s')}"}
    (48..83).to_a.each{|ku|r << "#{j.char(ku,1,'s')}-#{j.char(ku,94,'s')}"}
    (84).to_a.each{|ku|r << "#{j.char(ku,1,'s')}-#{j.char(ku,6,'s')}"}
    (89..91).to_a.each{|ku|r << "#{j.char(ku,1,'s')}-#{j.char(ku,94,'s')}"}#cp932
    (92).to_a.each{|ku|r << "#{j.char(ku,1,'s')}-#{j.char(ku,78,'s')}"}#cp932
    r
  end

  # utf8
  def utf8_ja_alnum()
    j = JIS0208.new
    r = []
    (3).to_a.each{|ku|(16..25).to_a.each{|ten|r << j.char(ku,ten,"u8")}}
    (3).to_a.each{|ku|(33..58).to_a.each{|ten|r << j.char(ku,ten,"u8")}}
    (3).to_a.each{|ku|(65..90).to_a.each{|ten|r << j.char(ku,ten,"u8")}}
    r
  end
  def utf8_ja_blank()
    j = JIS0208.new
    r = []
    (1).to_a.each{|ku|(1).to_a.each{|ten|r << j.char(ku,ten,"u8")}}
    r
  end
  def utf8_ja_print()
    utf8_ja_graph() + utf8_ja_blank()
  end
  def utf8_ja_graph()
    utf8_ja_alnum() + utf8_ja_punct()
  end
  def utf8_ja_punct()
    j = JIS0208.new
    r = []
    (1).to_a.each{|ku|( 2..94).to_a.each{|ten|r << j.char(ku,ten,"u8")}}
    (2).to_a.each{|ku|( 1..14).to_a.each{|ten|r << j.char(ku,ten,"u8")}}
    (2).to_a.each{|ku|(26..33).to_a.each{|ten|r << j.char(ku,ten,"u8")}}
    (2).to_a.each{|ku|(42..48).to_a.each{|ten|r << j.char(ku,ten,"u8")}}
    (2).to_a.each{|ku|(60..74).to_a.each{|ten|r << j.char(ku,ten,"u8")}}
    (2).to_a.each{|ku|(82..89).to_a.each{|ten|r << j.char(ku,ten,"u8")}}
    (2).to_a.each{|ku|(94    ).to_a.each{|ten|r << j.char(ku,ten,"u8")}}
    (6).to_a.each{|ku|( 1..24).to_a.each{|ten|r << j.char(ku,ten,"u8")}}
    (6).to_a.each{|ku|(33..56).to_a.each{|ten|r << j.char(ku,ten,"u8")}}
    (7).to_a.each{|ku|( 1..33).to_a.each{|ten|r << j.char(ku,ten,"u8")}}
    (7).to_a.each{|ku|(49..81).to_a.each{|ten|r << j.char(ku,ten,"u8")}}
    (8).to_a.each{|ku|( 1..32).to_a.each{|ten|r << j.char(ku,ten,"u8")}}
    r
  end
  def utf8_ja_space()
    j = JIS0208.new
    r = []
    (1).to_a.each{|ku|(1).to_a.each{|ten|r << j.char(ku,ten,"u8")}}
    r
  end
  def utf8_hiragana()
    j = JIS0208.new
    r = []
    (4).to_a.each{|ku|(1..83).to_a.each{|ten|r << j.char(ku,ten,"utf-8")}}
    r
  end
  def utf8_katakana()
    j = JIS0208.new
    r = []
    (5).to_a.each{|ku|(1..86).to_a.each{|ten|r << j.char(ku,ten,"utf-8")}}
    r
  end
  def utf8_kanji()
    j = JIS0208.new
    r = []
    (16..46).to_a.each{|ku|(1..94).to_a.each{|ten|r << j.char(ku,ten,"utf-8")}}
    (47).to_a.each{|ku|(1..51).to_a.each{|ten|r << j.char(ku,ten,"utf-8")}}
    (48..83).to_a.each{|ku|(1..94).to_a.each{|ten|r << j.char(ku,ten,"utf-8")}}
    (84).to_a.each{|ku|(1..6).to_a.each{|ten|r << j.char(ku,ten,"utf-8")}}
    r
  end

  jis0208 = JIS0208.new
  if ARGV.size == 3
    ku, ten, codeset = ARGV[0].to_i, ARGV[1].to_i, ARGV[2].to_s
    puts jis0208.char(ku, ten, codeset)
    exit(0)
  elsif ARGV.size == 2
    codeset, charclass = ARGV[0].to_s, ARGV[1].to_s
  else
    puts "Usage: jis0208.rb (<Ku> <Ten> <Codeset> | <Codeset> <CharClass>)"
    puts "Supported codeset:   EUC-JP, Shift_JIS, UTF-8"
    puts "Supported charclass: blank, space, alnum, punct, print, graph, hiragana, katakana, kanji"
    puts "Example 1: jis0208.rb 16 1 utf-8"
    puts "Example 2: jis0208.rb euc-jp punct"
    exit(0)
  end

  case
  when (/^e/i.match codeset)  # euc-jp
    case
    when (/^space/i.match charclass) then puts euc_ja_space()
    when (/^blank/i.match charclass) then puts euc_ja_blank()
    when (/^alnum/i.match charclass) then puts euc_ja_alnum()
    when (/^punct/i.match charclass) then puts euc_ja_punct()
    when (/^print/i.match charclass) then puts euc_ja_print()
    when (/^graph/i.match charclass) then puts euc_ja_graph()
    when (/^hira/i.match charclass) then puts euc_hiragana()
    when (/^kata/i.match charclass) then puts euc_katakana()
    when (/^kanji/i.match charclass) then puts euc_kanji()
    else
      raise "invalid charclass (#{charclass}).\n"
    end
  when (/^s/i.match codeset)  # sjis
    case
    when (/^space/i.match charclass) then puts sjis_ja_space()
    when (/^blank/i.match charclass) then puts sjis_ja_blank()
    when (/^alnum/i.match charclass) then puts sjis_ja_alnum()
    when (/^punct/i.match charclass) then puts sjis_ja_punct()
    when (/^print/i.match charclass) then puts sjis_ja_print()
    when (/^graph/i.match charclass) then puts sjis_ja_graph()
    when (/^hira/i.match charclass) then puts sjis_hiragana()
    when (/^kata/i.match charclass) then puts sjis_katakana()
    when (/^kanji/i.match charclass) then puts sjis_kanji()
    else
      raise "invalid charclass (#{charclass}).\n"
    end
  when (/^u/i.match codeset)  # utf-8
    case
    when (/^space/i.match charclass) then puts utf8_ja_space()
    when (/^blank/i.match charclass) then puts utf8_ja_blank()
    when (/^alnum/i.match charclass) then puts utf8_ja_alnum()
    when (/^punct/i.match charclass) then puts utf8_ja_punct()
    when (/^print/i.match charclass) then puts utf8_ja_print()
    when (/^graph/i.match charclass) then puts utf8_ja_graph()
    when (/^hira/i.match charclass) then puts utf8_hiragana()
    when (/^kata/i.match charclass) then puts utf8_katakana()
    when (/^kanji/i.match charclass) then puts utf8_kanji()
    else
      raise "invalid charclass (#{charclass}).\n"
    end
  else
    raise "invalid codeset (#{codeset}) or charclass (#{charclass}).\n"
  end

end
