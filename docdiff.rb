#!/usr/bin/ruby
# DocDiff 0.3
# 2002-06-27 Thu  .. 2002-08-15 Thu
# Hisashi MORITA

class DocDiff

  class App

    @version
    @copyright
    @usage

  end

  class Conf

    # order: built-in -> ~/.docdiffrc

  end

  class Document

    @type     # MIME type.  default is "text/plain".
    @language # "English", "Japanese", etc.
    @encoding # "ASCII", "EUC-JP", etc.
    @eol      # "\r", "\n", or "\r\n".
    # @header  # Manued document has tag definition in header.
    @body
    # @footer

    def compare_by_char_with(other_doc)
      #
    end

    def compare_by_word_with(other_doc)
      #
    end

    # def compare_by_sentence_with()
    # end

    # def compare_by_line_with()
    # end

  end  # class Document

  module SplittableString

    Encoding  = Hash.new
    EndOfLine = Hash.new

    def valid_enc_supplied
      if Encoding[@lang] && Encoding[@lang][@enc] && Encoding[@lang][@enc].type == Module
        true
      else
        false
      end
    end

    def valid_eol_supplied
      if @eol && EndOfLine[@eol] && EndOfLine[@eol].type == Module
        true
      else
        false
      end
    end

    def lang
      @lang
    end

    def lang=(l)
      @lang = l
      extend Encoding[@lang][@enc] if valid_enc_supplied
    end

    def enc
      @enc
    end

    def enc=(e)
      @enc = e
      extend Encoding[@lang][@enc] if valid_enc_supplied
    end

    def eol
      @eol
    end

    def eol=(e)
      @eol = e
      extend EndOfLine[@eol] if valid_eol_supplied
    end

    def debug
      case
      when @lang == nil then                         raise "@lang is nil."
      when @enc  == nil then                         raise "@enc is nil."
      when Encoding[@lang]       == nil then         raise "Encoding[@lang(=#{@lang})] is nil."
      when Encoding[@lang][@enc] == nil then         raise "Encoding[@lang(=#{@lang})][@enc(=#{@enc})] is nil."
      when Encoding[@lang][@enc].type != Module then raise "Encoding[@lang][@enc].type(=#{Encoding[@lang][@enc].type}) is not Module."
      when @eol == nil then raise "@eol is nil."
      when EndOfLine[@eol] == nil then raise "EndOfLine[@eol(=#{@eol})] is nil."
      end
      ["id: #{self.id}, type: #{self.type}, self: #{self}, module: #{Encoding[@lang][@enc]}, #{EndOfLine[@eol]}"]
    end

    def SplittableString.register_encoding(encoding_module)
      Encoding[encoding_module::LANG] || Encoding[encoding_module::LANG] = Hash.new
      Encoding[encoding_module::LANG][encoding_module::ENC] = encoding_module
    end

    def SplittableString.register_eol(eol_module)
      EndOfLine[eol_module::EOL] = eol_module
    end

    module ASCIIEn

      LANG = "English"
      ENC  = "ASCII"

      # ASCII alphabet, number, and hyphen (good-bye is one word)
      UB_ALNUM = '(?:[0-9A-Za-z_\-])'
      # ASCII printable symbols, excluding hyphen ('-', 0x2d)
      UB_SYM1 = '(?:[\x20-\x2c])|(?:[\x2e-\x2f])' # 0x20-0x2f ( !"#$%&'()*+,-./)
      UB_SYM2 = '(?:[\x3a-\x40])'                 # :;<=>?@)
      UB_SYM3 = '(?:[\x5b-\x5e])'                 # [\]^
      UB_SYM4 = '(?:\x60)'                        # `
      UB_SYM5 = '(?:[\x7b-\x7e])'                 # {|}~
      UB_SYMBOL = "(?:#{UB_SYM1}|#{UB_SYM2}|#{UB_SYM3}|#{UB_SYM4}|#{UB_SYM5})"
      UB_CONTROL = '(?:[\x00-\x1f])' # ASCII control chars
      # make Regexp
      # RE_UB_ALNUM    = Regexp.new("^#{UB_ALNUM}+")
      # RE_UB_SYMBOL   = Regexp.new("^#{UB_SYMBOL}")
      # RE_UB_CONTROL  = Regexp.new("^#{UB_CONTROL}")
      word_pattern = " ?#{UB_ALNUM}+|.+?"
      WordPattern = Regexp.compile(word_pattern, Regexp::MULTILINE, "n")

      def to_char
        split(//n)
      end

      def to_word
        scan(WordPattern)
      end

      SplittableString.register_encoding(self)

    end

    module UTF8En

      LANG = "English"
      ENC  = "UTF-8"

      def to_char
        split(//u)
      end

      def to_word
        raise "not implemented yet."
      end

      SplittableString.register_encoding(self)

    end

    module EUCJP

      LANG = "Japanese"
      ENC  = "EUC-JP"

      # UB_*: unibyte, MB_*: multibyte
      # ASCII alphabet, number, and hyphen (good-bye is one word).
      UB_ALNUM = '(?:[0-9A-Za-z_\-])'
      # ASCII printable symbols (excluding hyphen ('-', 0x2d)):
      UB_SYM1 = '(?:[\x20-\x2c])|(?:[\x2e-\x2f])' # 0x20-0x2f
                                                  #  !"#$%&'()*+,-./
      UB_SYM2 = '(?:[\x3a-\x40])'                 # :;<=>?@
      UB_SYM3 = '(?:[\x5b-\x5e])'                 # [\]^
      UB_SYM4 = '(?:\x60)'                        # `)
      UB_SYM5 = '(?:[\x7b-\x7e])'                 # {|}~
      UB_SYMBOL = "(?:#{UB_SYM1}|#{UB_SYM2}|#{UB_SYM3}|#{UB_SYM4}|#{UB_SYM5})"
      UB_CONTROL = '(?:[\x00-\x1f])'   # ASCII control characters
      UB_KATA = '(?:\x8e[\x21-\x5f])'  # EUC-JP unicolumn katakana (0x8e21-0x8e5f)
      # multibyte symbol (excluding macron("onbiki") and repeat("noma")):
      # 0xa1a1-0xa1b8, 0xa1ba-0xa1bb, 0xa1bd-0xa1fe, 0xa2a1-0xa2fe
      # macron is included in katakana, Noma in kanji.
      # exception: ¥Î¥Þ(¡¹)       # repeat previous kanji
      #            ²¾Ì¾ÊÖ¤·: ¡³¡´   # repeat previous hiragana
      #                      ¡µ¡¶ # repeat previous katakana
      #                      ¡·   # repeat previous element in chart/table
      # !! these exceptions above are not yet implemented !!!
      MB_SYMBOL = '(?:(?:\xa1[\xa1-\xb8\xba-\xbb\xbd-\xfe])|(?:\xa2[\xa1-\xfe]))'
      MB_ALNUM = '(?:\xa3[\xb0-\xff])'  # mb alphabet and number: 0xa3b0-0xa3ff
      MB_HIRA  = '(?:\xa4[\xa1-\xfe])'  # mb hiragana: 0xa4a1-0xa4fe
      # mb katakana: 0xa5a1-0xa5fe, including 0xa1bc(=macron, onbiki)
      MB_KATA = '(?:(?:\xa5[\xa1-\xfe])|(?:\xa1\xbc))'
      MB_GREEK    = '(?:\xa6[\xa1-\xfe])'  # mb Greek: 0xa6a1-0xa6fe
      MB_CYRILLIC = '(?:\xa7[\xa1-\xfe])'  # mb Cyrillic: 0xa7a1-0xa7fe
      # mb box drawing symbol (=keisen): 0xa8a1-0xa8fe
      MB_BOXDRAW  = '(?:\xa8[\xa1-\xfe])'
      # mb undefined area (vendor dependent): 0xa9a1-0xacfe, 0xaea1-0xaffe
      MB_UNDEFINED = '(?:(?:[\xa9-\xac][\xa1-\xfe])|(?:[\xae-\xaf][\xa1-\xfe]))'
      # mb NEC-only symbol: 0xada1-0xadfe
      MB_SYMBOL_NEC = '(?:\xad[\xa1-\xfe])'
      # mb kanji: 0xb0a1-0xfefe, 0xa1b9(="Kuma", kanji repetition symbol)
      # (actually this area includes undefined/NEC-kanji area)
      MB_KANJI = '(?:(?:[\xb0-\xfe][\xa1-\xfe])|(?:\xa1\xb9))'
      # RE_MB_KANHIRA  = Regexp.new("^#{MB_KANJI}+#{MB_HIRA}+") #experimental
      # RE_MB_KATAHIRA = Regexp.new("^#{MB_KATA}+#{MB_HIRA}+")  #experimental
      # RE_UB_ALNUM    = Regexp.new("^#{UB_ALNUM}+")
      # RE_UB_SYMBOL   = Regexp.new("^#{UB_SYMBOL}")
      # RE_UB_CONTROL  = Regexp.new("^#{UB_CONTROL}")
      # RE_UB_KATA     = Regexp.new("^#{UB_KATA}+")
      # RE_MB_SYMBOL   = Regexp.new("^#{MB_SYMBOL}|#{MB_GREEK}" +
      #                             "|#{MB_CYRILLIC}|#{MB_BOXDRAW}" +
      #                             "|#{MB_SYMBOL_NEC}|#{MB_UNDEFINED}")
      # RE_MB_ALNUM    = Regexp.new("^#{MB_ALNUM}+")
      # RE_MB_HIRA     = Regexp.new("^#{MB_HIRA}+")
      # RE_MB_KATA     = Regexp.new("^#{MB_KATA}+")
      # RE_MB_KANJI    = Regexp.new("^#{MB_KANJI}+")
      word_pattern = " ?#{UB_ALNUM}+|#{MB_HIRA}+|#{MB_KATA}+|#{MB_KANJI}+|.+?"
      WordPattern = Regexp.compile(word_pattern, Regexp::MULTILINE, "e")

      def to_char
        split(//e)
      end

      def to_word
        scan(WordPattern)
      end

      SplittableString.register_encoding(self)

    end

    module ShiftJIS

      LANG = "Japanese"
      ENC  = "Shift_JIS"

      # ASCII alphabet, number, and hyphen (so that good-bye is treated as 1 word).
      UB_ALNUM = '(?:[0-9A-Za-z_\-])'
      # ASCII printable symbols (excluding hyphen ('-', 0x2d)):
      UB_SYM1 = '(?:[\x20-\x2c])|(?:[\x2e-\x2f])' # 0x20-0x2f ( !"#$%&'()*+,-./)
      UB_SYM2 = '(?:[\x3a-\x40])'                 # 0x3a-0x40 (:;<=>?@)
      UB_SYM3 = '(?:[\x5b-\x5e])'                 # 0x5b-0x5e ([\]^)
      UB_SYM4 = '(?:\x60)'                        # 0x60      (`)
      UB_SYM5 = '(?:[\x7b-\x7e])'                 # 0x7b-0x7e ({|}~)
      UB_SYMBOL = "(?:#{UB_SYM1}|#{UB_SYM2}|#{UB_SYM3}|#{UB_SYM4}|#{UB_SYM5})"
      UB_CONTROL = '(?:[\x00-\x1f])' # ASCII control characters
      UB_KATA = '(?:[\xa1-\xdf])'    # SJIS unibyte katakana (0xa1-0xdf)
      # multibyte symbol (excluding macron("onbiki") and repeat("noma")):
      # 0x8141-0x8157, 0x8159-0x815a, 0x815c-0x819e, 0x819f-0x81fc
      # macron is included in katakana, Noma in kanji.
      # exception: ¥Î¥Þ(¡¹)       # repeat previous kanji
      #            ²¾Ì¾ÊÖ¤·: ¡³¡´ # repeat previous hiragana
      #                      ¡µ¡¶ # repeat previous katakana
      #                      ¡·   # repeat previous element in chart/table
      # !! these exceptions above are not yet implemented !!!
      MB_SYMBOL = '(?:\x81[\x41-\x57\x59-\x5a\x5c-\x9e\x9f-\xfc])'
      MB_ALNUM = '(?:\x82[\x4f-\x9e])'  # mb alphabet and number: 0x824f-0x829e
      MB_HIRA  = '(?:\x82[\x9f-\xff])'  # mb hiragana: 0x829f-0x82ff
      # mb katakana: 0x8340-0x839e, including 0x815b(=macron, onbiki)
      MB_KATA = '(?:(?:\x83[\x40-\x9e])|(?:\x81\x5b))'
      MB_GREEK    = '(?:\x83[\x9f-\xd6])'  # mb Greek: 0x839f-0x83d6
      MB_CYRILLIC = '(?:\x84[\x40-\x91])'  # mb Cyrillic: 0x8440-0x8491
      # mb box drawing symbol (=keisen): 0x849f-0x84be
      MB_BOXDRAW  = '(?:\x84[\x9f-\xbe])'
      # mb undefined area (vendor dependent): 0x8540-0x86fe, 0x879f-0x889c
      MB_UNDEFINED = '(?:(?:\x85[\x40-\x9c])|(?:\x86[\x40-\xfe])|' +
                     '(?:\x87[\x9f-\xfd)|(?:\x88[\x40-\x9c]))'
      # mb NEC-only symbol: 0x8740-0x879e
      MB_SYMBOL_NEC = '(?:\x87[\x40-\x9e])'
      # mb kanji: 0x889f-0xeffc, 0x8158(="Noma", kanji repetition symbol)
      # (actually this area includes undefined/NEC-kanji area)
      MB_KANJI = '(?:(?:\x88[\x9f-\xfc])|(?:[\x89-\xef][\x00-\xff])|(?:\x81\x58))'
      # RE_MB_KANHIRA  = Regexp.new("^#{MB_KANJI}+#{MB_HIRA}+")
      # RE_MB_KATAHIRA = Regexp.new("^#{MB_KATA}+#{MB_HIRA}+")
      # RE_UB_ALNUM    = Regexp.new("^#{UB_ALNUM}+")
      # RE_UB_SYMBOL   = Regexp.new("^#{UB_SYMBOL}")
      # RE_UB_CONTROL  = Regexp.new("^#{UB_CONTROL}")
      # RE_UB_KATA     = Regexp.new("^#{UB_KATA}+")
      # RE_MB_SYMBOL   = Regexp.new("^#{MB_SYMBOL}|#{MB_GREEK}|#{MB_CYRILLIC}" +
      #                              "|#{MB_BOXDRAW}|#{MB_SYMBOL_NEC}" +
      #                              "|#{MB_UNDEFINED}")
      # RE_MB_ALNUM    = Regexp.new("^#{MB_ALNUM}+")
      # RE_MB_HIRA     = Regexp.new("^#{MB_HIRA}+")
      # RE_MB_KATA     = Regexp.new("^#{MB_KATA}+")
      # RE_MB_KANJI    = Regexp.new("^#{MB_KANJI}+")
      word_pattern = " ?#{UB_ALNUM}+|#{MB_HIRA}+|#{MB_KATA}+|#{MB_KANJI}+|.+?"
      WordPattern = Regexp.compile(word_pattern, Regexp::MULTILINE, "s")

      def to_char
        split(//s)
      end

      def to_word
        scan(WordPattern)
      end

      SplittableString.register_encoding(self)

    end

    module UTF8Ja

      LANG = "Japanese"
      ENC  = "UTF-8"

      def to_char
        split(//u)
      end

      def to_word
        raise "not implemented yet."
      end

      SplittableString.register_encoding(self)

    end

    module CR

      EOL = "\r"

      def to_line
        scan(/.*?\r|.+/m)
      end

      SplittableString.register_eol(self)

    end

    module LF

      EOL = "\n"

      def to_line
        scan(/.*?\n|.+/m)
      end

      SplittableString.register_eol(self)

    end

    module CRLF

      EOL = "\r\n"

      def to_line
        scan(/.*?\r\n|.+/m)
      end

      SplittableString.register_eol(self)

    end

  end  # module SplittableString

  class Difference

    @resolution  # char, word, ...
    @body

    module Formatter

      def to_html()
        #
      end

      def to_xhtml()
        #
      end

      def to_manued()
        #
      end

      def to_docdiff()
        #
      end

    end  # module Formatter

  end  # class Difference

end  # module DocDiff

if $0 == __FILE__

end
