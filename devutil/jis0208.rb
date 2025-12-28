#!/usr/bin/ruby
# frozen_string_literal: true

# Extracts multibyte characters from JIS0208.TXT.
# (ftp://ftp.unicode.org/Public/MAPPINGS/OBSOLETE/EASTASIA/JIS/JIS0208.TXT)
# 2003-03-03 .. 20xx-xx-xx, Hisashi MORITA.  Use freely at your own risk.
# Usage:   jis0208.rb <Ku> <Ten> <Codeset> #=> \xXX...
# Example: jis0208.rb 1 1 utf-8            #=> \xe3\x80\x80

Encoding.default_external = "UTF-8"

class JIS0208
  # Convert UTF-16 to UTF-8
  def utf16_to_utf8(utf16)
    utf16value =
      utf16.unpack("C*")[0] * 256 + utf16.unpack("C*")[1]
    utf8 =
      if utf16value < 0x7f
        # 1-byte UTF-8
        [utf16value].pack("C*")
      elsif utf16value < 0x800
        # 2-byte UTF-8
        [
          (0xC0 | (utf16value / 64)),
          (0x80 | (utf16value % 64)),
        ].pack("C*")
      else
        # 3-byte UTF-8
        [
          (0xE0 | ((utf16value / 64) / 64)),
          (0x80 | ((utf16value / 64) % 64)),
          (0x80 | (utf16value % 64)),
        ].pack("C*")
      end
    utf8
  end

  def initialize
    @lines = File.readlines("JIS0208.TXT")
    @lines = @lines.grep(/^[^\#]/) # remove comments
    @lines = @lines.map { |l| l.sub(/\s+\#[^\#]+$/, "") } # remove unicode names
    @char_db = @lines.collect do |line|
      sjis, jis, utf16 = line.split.map do |string|
        [string.sub("0x", "")].pack("H*") # "0xXXXX" to 8-bit byte string
      end
      jis_byte_pair = jis.unpack("C*")
      # jis + 0x8080 => euc
      euc = jis_byte_pair.map { |byte| (byte + 0x80) }.pack("C*")
      # jis - 0x2020 => ku, ten
      ku, ten = jis_byte_pair.map { |byte| (byte - 0x20) }
      utf8 = utf16_to_utf8(utf16)
      {
        s: sjis,
        j: jis,
        u16: utf16,
        e: euc,
        u8: utf8,
        ku: ku,
        ten: ten,
      }
    end
    @characters = {}
    @char_db.each do |char|
      if @characters[char[:ku]].nil?
        @characters[char[:ku]] = {}
      end
      if @characters[char[:ku]][char[:ten]].nil?
        @characters[char[:ku]][char[:ten]] = {
          s: char[:s],
          j: char[:j],
          u16: char[:u16],
          e: char[:e],
          u8: char[:u8],
        }
      end
    end
  end
  attr_reader :char_db
  attr_reader :characters

  def char(ku, ten, codeset_name)
    codeset =
      case codeset_name
      when /^[Ee]/ then :e
      when /^[Ss]/ then :s
      when /^[Jj]/ then :j
      when /^[Uu].*16$/ then :u16
      when /^[Uu].*8$/ then :u8
      else
        raise "invalid codeset name (#{codeset_name})"
      end

    characters[ku][ten][codeset].unpack("C*").map do |byte|
      format("\\x%x", byte)
    end.join
  end

  def euc_ja_alnum
    r = []
    [3].each { |ku| (16..25).to_a.each { |ten| r << char(ku, ten, "e") } }
    [3].each { |ku| (33..58).to_a.each { |ten| r << char(ku, ten, "e") } }
    [3].each { |ku| (65..90).to_a.each { |ten| r << char(ku, ten, "e") } }
    r
  end

  def euc_ja_blank
    r = []
    [1].each { |ku| [1].each { |ten| r << char(ku, ten, "e") } }
    r
  end

  def euc_ja_print
    euc_ja_graph + euc_ja_blank
  end

  def euc_ja_graph
    euc_ja_alnum + euc_ja_punct
  end

  def euc_ja_punct
    r = []
    [1].each { |ku| (2..94).to_a.each  { |ten| r << char(ku, ten, "e") } }
    [2].each { |ku| (1..14).to_a.each  { |ten| r << char(ku, ten, "e") } }
    [2].each { |ku| (26..33).to_a.each { |ten| r << char(ku, ten, "e") } }
    [2].each { |ku| (42..48).to_a.each { |ten| r << char(ku, ten, "e") } }
    [2].each { |ku| (60..74).to_a.each { |ten| r << char(ku, ten, "e") } }
    [2].each { |ku| (82..89).to_a.each { |ten| r << char(ku, ten, "e") } }
    [2].each { |ku| [94].each          { |ten| r << char(ku, ten, "e") } }
    [6].each { |ku| (1..24).to_a.each  { |ten| r << char(ku, ten, "e") } }
    [6].each { |ku| (33..56).to_a.each { |ten| r << char(ku, ten, "e") } }
    [7].each { |ku| (1..33).to_a.each  { |ten| r << char(ku, ten, "e") } }
    [7].each { |ku| (49..81).to_a.each { |ten| r << char(ku, ten, "e") } }
    [8].each { |ku| (1..32).to_a.each  { |ten| r << char(ku, ten, "e") } }
    r
  end

  def euc_ja_space
    r = []
    [1].each { |ku| [1].each { |ten| r << char(ku, ten, "e") } }
    r
  end

  def euc_hiragana
    r = []
    [4].each { |ku| (1..83).to_a.each { |ten| r << char(ku, ten, "e") } }
    r
  end

  def euc_katakana
    r = []
    [5].each { |ku| (1..86).to_a.each { |ten| r << char(ku, ten, "e") } }
    r
  end

  def euc_kanji
    r = []
    (16..46).to_a.each { |ku| r << "#{char(ku, 1, "e")}-#{char(ku, 94, "e")}" }
    [47].each          { |ku| r << "#{char(ku, 1, "e")}-#{char(ku, 51, "e")}" }
    (48..83).to_a.each { |ku| r << "#{char(ku, 1, "e")}-#{char(ku, 94, "e")}" }
    [84].each          { |ku| r << "#{char(ku, 1, "e")}-#{char(ku, 6, "e")}" }
    r
  end

  def sjis_ja_alnum
    r = []
    [3].each { |ku| (16..25).to_a.each { |ten| r << char(ku, ten, "s") } }
    [3].each { |ku| (33..58).to_a.each { |ten| r << char(ku, ten, "s") } }
    [3].each { |ku| (65..90).to_a.each { |ten| r << char(ku, ten, "s") } }
    r
  end

  def sjis_ja_blank
    r = []
    [1].each { |ku| [1].each { |ten| r << char(ku, ten, "s") } }
    r
  end

  def sjis_ja_print
    sjis_ja_graph + sjis_ja_blank
  end

  def sjis_ja_graph
    sjis_ja_alnum + sjis_ja_punct
  end

  def sjis_ja_punct
    r = []
    [1].each { |ku| (2..94).to_a.each  { |ten| r << char(ku, ten, "s") } }
    [2].each { |ku| (1..14).to_a.each  { |ten| r << char(ku, ten, "s") } }
    [2].each { |ku| (26..33).to_a.each { |ten| r << char(ku, ten, "s") } }
    [2].each { |ku| (42..48).to_a.each { |ten| r << char(ku, ten, "s") } }
    [2].each { |ku| (60..74).to_a.each { |ten| r << char(ku, ten, "s") } }
    [2].each { |ku| (82..89).to_a.each { |ten| r << char(ku, ten, "s") } }
    [2].each { |ku| [94].each          { |ten| r << char(ku, ten, "s") } }
    [6].each { |ku| (1..24).to_a.each  { |ten| r << char(ku, ten, "s") } }
    [6].each { |ku| (33..56).to_a.each { |ten| r << char(ku, ten, "s") } }
    [7].each { |ku| (1..33).to_a.each  { |ten| r << char(ku, ten, "s") } }
    [7].each { |ku| (49..81).to_a.each { |ten| r << char(ku, ten, "s") } }
    [8].each { |ku| (1..32).to_a.each  { |ten| r << char(ku, ten, "s") } }
    # [13].each { |ku| (1..30).to_a.each  { |ten| r << char(ku, ten, "s") } } # cp932
    # [13].each { |ku| (32..54).to_a.each { |ten| r << char(ku, ten, "s") } } # cp932
    # [13].each { |ku| (63..92).to_a.each { |ten| r << char(ku, ten, "s") } } # cp932
    # [92].each { |ku| (81..94).to_a.each { |ten| r << char(ku, ten, "s") } } # cp932
    r
  end

  def sjis_ja_space
    r = []
    [1].each { |ku| [1].each { |ten| r << char(ku, ten, "s") } }
    r
  end

  def sjis_hiragana
    r = []
    [4].each { |ku| (1..83).to_a.each { |ten| r << char(ku, ten, "s") } }
    r
  end

  def sjis_katakana
    r = []
    [5].each { |ku| (1..86).to_a.each { |ten| r << char(ku, ten, "s") } }
    r
  end

  def sjis_kanji
    r = []
    (16..46).to_a.each { |ku| r << "#{char(ku, 1, "s")}-#{char(ku, 94, "s")}" }
    [47].each          { |ku| r << "#{char(ku, 1, "s")}-#{char(ku, 51, "s")}" }
    (48..83).to_a.each { |ku| r << "#{char(ku, 1, "s")}-#{char(ku, 94, "s")}" }
    [84].each          { |ku| r << "#{char(ku, 1, "s")}-#{char(ku, 6, "s")}" }
    # (89..91).to_a.each { |ku| r << "#{char(ku, 1, "s")}-#{char(ku, 94, "s")}" } # cp932 # FIXME
    # [92].each          { |ku| r << "#{char(ku, 1, "s")}-#{char(ku, 78, "s")}" } # cp932 # FIXME
    r
  end

  def utf8_ja_alnum
    r = []
    [3].each { |ku| (16..25).to_a.each { |ten| r << char(ku, ten, "u8") } }
    [3].each { |ku| (33..58).to_a.each { |ten| r << char(ku, ten, "u8") } }
    [3].each { |ku| (65..90).to_a.each { |ten| r << char(ku, ten, "u8") } }
    r
  end

  def utf8_ja_blank
    r = []
    [1].each { |ku| [1].each { |ten| r << char(ku, ten, "u8") } }
    r
  end

  def utf8_ja_print
    utf8_ja_graph + utf8_ja_blank
  end

  def utf8_ja_graph
    utf8_ja_alnum + utf8_ja_punct
  end

  def utf8_ja_punct
    r = []
    [1].each { |ku| (2..94).to_a.each  { |ten| r << char(ku, ten, "u8") } }
    [2].each { |ku| (1..14).to_a.each  { |ten| r << char(ku, ten, "u8") } }
    [2].each { |ku| (26..33).to_a.each { |ten| r << char(ku, ten, "u8") } }
    [2].each { |ku| (42..48).to_a.each { |ten| r << char(ku, ten, "u8") } }
    [2].each { |ku| (60..74).to_a.each { |ten| r << char(ku, ten, "u8") } }
    [2].each { |ku| (82..89).to_a.each { |ten| r << char(ku, ten, "u8") } }
    [2].each { |ku| [94].each          { |ten| r << char(ku, ten, "u8") } }
    [6].each { |ku| (1..24).to_a.each  { |ten| r << char(ku, ten, "u8") } }
    [6].each { |ku| (33..56).to_a.each { |ten| r << char(ku, ten, "u8") } }
    [7].each { |ku| (1..33).to_a.each  { |ten| r << char(ku, ten, "u8") } }
    [7].each { |ku| (49..81).to_a.each { |ten| r << char(ku, ten, "u8") } }
    [8].each { |ku| (1..32).to_a.each  { |ten| r << char(ku, ten, "u8") } }
    r
  end

  def utf8_ja_space
    r = []
    [1].each { |ku| [1].each { |ten| r << char(ku, ten, "u8") } }
    r
  end

  def utf8_hiragana
    r = []
    [4].each { |ku| (1..83).to_a.each { |ten| r << char(ku, ten, "utf-8") } }
    r
  end

  def utf8_katakana
    r = []
    [5].each { |ku| (1..86).to_a.each { |ten| r << char(ku, ten, "utf-8") } }
    r
  end

  def utf8_kanji
    r = []
    (16..46).to_a.each { |ku| (1..94).to_a.each { |ten| r << char(ku, ten, "utf-8") } }
    [47].each          { |ku| (1..51).to_a.each { |ten| r << char(ku, ten, "utf-8") } }
    (48..83).to_a.each { |ku| (1..94).to_a.each { |ten| r << char(ku, ten, "utf-8") } }
    [84].each          { |ku| (1..6).to_a.each { |ten| r << char(ku, ten, "utf-8") } }
    r
  end
end

if __FILE__ == $PROGRAM_NAME
  jis0208 = JIS0208.new

  if ARGV.size == 3
    ku = ARGV[0].to_i
    ten = ARGV[1].to_i
    codeset = ARGV[2]
    puts jis0208.char(ku, ten, codeset)
    exit(0)
  elsif ARGV.size == 2
    codeset = ARGV[0]
    charclass = ARGV[1]
  else
    puts <<~EOS
      Usage: jis0208.rb (<Ku> <Ten> <Codeset> | <Codeset> <CharClass>)
      Supported codeset:   EUC-JP, Shift_JIS, UTF-8
      Supported charclass: blank, space, alnum, punct, print, graph, hiragana, katakana, kanji
      Example 1: jis0208.rb 16 1 utf-8 #=> \xe4\xba\x9c
      Example 2: jis0208.rb euc-jp punct #=> \xa1\xa2 ... \xa8\xc0
    EOS
    exit(0)
  end

  output =
    case codeset
    when /^e/i # euc-jp
      case charclass
      when /^space/i then jis0208.euc_ja_space
      when /^blank/i then jis0208.euc_ja_blank
      when /^alnum/i then jis0208.euc_ja_alnum
      when /^punct/i then jis0208.euc_ja_punct
      when /^print/i then jis0208.euc_ja_print
      when /^graph/i then jis0208.euc_ja_graph
      when /^hira/i  then jis0208.euc_hiragana
      when /^kata/i  then jis0208.euc_katakana
      when /^kanji/i then jis0208.euc_kanji
      else
        raise "invalid charclass (#{charclass})"
      end
    when /^s/i # sjis
      case charclass
      when /^space/i then jis0208.sjis_ja_space
      when /^blank/i then jis0208.sjis_ja_blank
      when /^alnum/i then jis0208.sjis_ja_alnum
      when /^punct/i then jis0208.sjis_ja_punct
      when /^print/i then jis0208.sjis_ja_print
      when /^graph/i then jis0208.sjis_ja_graph
      when /^hira/i  then jis0208.sjis_hiragana
      when /^kata/i  then jis0208.sjis_katakana
      when /^kanji/i then jis0208.sjis_kanji
      else
        raise "invalid charclass (#{charclass})"
      end
    when /^u/i # utf-8
      case charclass
      when /^space/i then jis0208.utf8_ja_space
      when /^blank/i then jis0208.utf8_ja_blank
      when /^alnum/i then jis0208.utf8_ja_alnum
      when /^punct/i then jis0208.utf8_ja_punct
      when /^print/i then jis0208.utf8_ja_print
      when /^graph/i then jis0208.utf8_ja_graph
      when /^hira/i  then jis0208.utf8_hiragana
      when /^kata/i  then jis0208.utf8_katakana
      when /^kanji/i then jis0208.utf8_kanji
      else
        raise "invalid charclass (#{charclass})"
      end
    else
      raise "invalid codeset (#{codeset}) or charclass (#{charclass})"
    end

  puts output
end
