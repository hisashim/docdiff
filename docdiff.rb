#!/usr/bin/ruby
# DocDiff 0.3
# 2002-06-27 Thu ...
# Hisashi MORITA

class DocDiff

  class App

    # @version
    # @copyright
    # @usage

  end

  class Conf

    # priority: default < ~/.docdiff < command line option

  end

  class Document

    def initialize(text_body)
      @type       = "text/plain"  # MIME type.
      @header     = nil    # Manued has header.
      @body       = text_body
      @footer     = nil
      attr_accessor :type, :header, :body, :footer
      @language   = nil    # "English", "Japanese", etc.
      @encoding   = nil    # "ASCII", "EUC-JP", etc.
      @end_of_ine = nil    # "\r", "\n", or "\r\n".
    end

    def language()
      @body.lang
    end

    def language=(l)
      @body.lang = l
    end

    def encoding()
      @body.enc
    end

    def encoding=(e)
      @body.enc = e
    end

    def end_of_line()
      @body.eol
    end

    def end_of_line=(nl)
      @body.eol = nl
    end

    def compare_by_char_with(other_doc)
    end

    def compare_by_word_with(other_doc)
    end

    def compare_by_phrase_with(other_doc)
    end

    def compare_by_sentence_with(other_doc)
    end

    def compare_by_line_with(other_doc)
    end

    def compare_by_paragraph_with(other_doc)
    end

  end  # class Document

  module StringPlus

    Encoding  = Hash.new
    EndOfLine = Hash.new

    def lang()
      @lang
    end
    def lang=(l)
      @lang = l
      extend Encoding[@lang][@enc] if valid_enc_supplied
    end
    def enc()
      @enc
    end
    def enc=(e)
      @enc = e
      extend Encoding[@lang][@enc] if valid_enc_supplied
    end
    def eol()
      @eol
    end
    def eol=(e)
      @eol = e
      extend EndOfLine[@eol] if valid_eol_supplied
    end

    def valid_enc_supplied()
      return false if Encoding[@lang].nil?
      return false if Encoding[@lang][@enc].nil?
      return false if Encoding[@lang][@enc].type != Module
      return true
    end

    def valid_eol_supplied()
      return false if @eol.nil?
      return false if EndOfLine[@eol].nil?
      return false if EndOfLine[@eol].type != Module
      return true
    end

    def debug()
      case
      when @lang == nil
        raise "@lang is nil."
      when @enc  == nil
        raise "@enc is nil."
      when Encoding[@lang] == nil
        raise "Encoding[@lang(=#{@lang})] is nil."
      when Encoding[@lang][@enc] == nil
        raise "Encoding[@lang(=#{@lang})][@enc(=#{@enc})] is nil."
      when Encoding[@lang][@enc].type != Module
        raise "Encoding[@lang][@enc].type" + 
              "(=#{Encoding[@lang][@enc].type}) is not Module."
      when @eol == nil
        raise "@eol is nil."
      when EndOfLine[@eol] == nil
        raise "EndOfLine[@eol(=#{@eol})] is nil."
      end
      ["id: #{self.id}"+", type: #{self.type}"+", self: #{self}" + 
       ", module: #{Encoding[@lang][@enc]}"+", #{EndOfLine[@eol]}"]
    end

    def StringPlus.register_encoding(enc_mod)
      Encoding[enc_mod::LANG] || 
        Encoding[enc_mod::LANG] = Hash.new
      Encoding[enc_mod::LANG][enc_mod::ENC] = enc_mod
    end

    def StringPlus.register_eol(eol_mod)
      EndOfLine[eol_mod::EOL] = eol_mod
    end

    # Virtual methods, which should be implemented 
    # in each encoding modules.
    # only "char" and "line" are well-defined and thus accurate. 
    # other units are bogus.

    def to_char()
    end

    def to_word()
    end

    def to_phrase()
    end

    def to_sentence()
    end

    def to_line()
    end

    def to_paragraph()
    end

    def count_char() # human-readable char only. (no space and eol)
    end

    def count_word() # not meant to be accurate.
    end

    def count_phrase() # not meant to be accurate.
    end

    def count_sentence() # not meant to be accurate.
    end

    def count_line()  # this is common to all encodings.
      to_line.size
    end

    def count_paragraph() # not meant to be accurate.
    end

    module English

      # strings to be defined in encoding modules:
      # 
      # WORD_DELIMITER
      # WORD_PREFIX
      # WORD_BODY
      # WORD_SUFFIX
      # self.EOL.system
      # 

      def word_pattern(encoding)
        "#{encoding::EXCEPTIONS}" + 
        "|#{encoding::UB_SYMBOL} ?" + 
        "|#{encoding::UB_ALNUM}+ ?|.+?"
      end
      module_function :word_pattern

      module ASCIIEn

        LANG = "English"
        ENC  = "ASCII"

        # ASCII alphanumeric characters and hyphen 
        # (so that "good-bye" be one word)
        UB_ALNUM = '(?:[0-9A-Za-z_\-])'
        UB_ALNUM_WORD = '(?:[0-9A-Za-z_\-\'\.])'  # ★★★リファクタリング中と言えば聞こえはいいが、実際には単なるデバグ中★★★
        # ASCII printable symbols, excluding hyphen ('-', 0x2d)
        UB_SYMBOL = "(?:(?:[\x20-\x2c])" + # !"#$%&'()*+,
                    "|(?:[\x2e-\x2f])" +   # ./
                    "|(?:[\x3a-\x40])" +   # :;<=>?@)
                    "|(?:[\x5b-\x5e])" +   # [\]^
                    "|(?:\x60)" +          # `
                    "|(?:[\x7b-\x7e]))"    # {|}~
        # ASCII control chars
        UB_CONTROL = '(?:[\x00-\x1f])'
        EXCEPTIONS=["Mr. ?","Mrs. ?","Ms. ?","Dr. ?","etc. ?",
                    "#{UB_ALNUM}*\'#{UB_ALNUM}* ?"].join('|')

        WordPattern = Regexp.new(English::word_pattern(self), 
                                 Regexp::MULTILINE, "n")

        def to_char()
          split(//n)
        end

        def to_word()
          scan(WordPattern)
        end

        def to_line()
        end

        def to_sentense()
        end

        def to_paragraph()
        end

        StringPlus.register_encoding(self)

      end

      module UTF8En

        LANG = "English"
        ENC  = "UTF-8"

        def to_char()
          split(//u)
        end

        def to_word()
          raise "not implemented yet."
        end

        def to_line()
        end

        def to_sentense()
        end

        def to_paragraph()
        end

        StringPlus.register_encoding(self)

      end
    end

    module Japanese

      def word_pattern(encoding)
        "#{encoding::UB_ALNUM_ABB}+ ?" + 
        "|#{encoding::MB_KANJI}+#{encoding::MB_HIRA}+" + 
        "|#{encoding::MB_KATA}+#{encoding::MB_HIRA}+" + 
        "|#{encoding::MB_KANJI}+" + 
	"|#{encoding::MB_KATA}+" + 
        "|#{encoding::MB_HIRA_MACRON}+" + 
        "|.+?"
      end
      module_function :word_pattern

      module EUCJP

        LANG = "Japanese"
        ENC  = "EUC-JP"

        # UB_*: unibyte, MB_*: multibyte
        # ASCII printable symbols
        # (excluding hyphen ('-', 0x2d)):
        UB_SYMBOL="(?:(?:[\x20-\x2c])" +  # !"#$%&'()*+,
                  "|(?:[\x2e-\x2f])" +    # ./
                  "|(?:[\x3a-\x40])" +    # :;<=>?@
                  "|(?:[\x5b-\x5e])" +    # [\]^
                  "|(?:\x60)" +           # `)
                  "|(?:[\x7b-\x7e]))"     # {|}~

        # ASCII control characters
        UB_CONTROL = '(?:[\x00-\x1f])'

        # ASCII alphabet, number, and hyphen
        # (so that good-bye is one word).
        UB_ALNUM = '(?:[0-9A-Za-z_\-])'
        UB_ALNUM_ABB = 
          "(?:Mr.|Mrs.|Ms.|Dr.|etc." + 
          "|I\'m|I\'ve|I\'ll|I\'d" + 
          "|[Ww]e\'re|[Ww]e\'ve|[Ww]e\'ll|[Ww]e\'d" + 
          "|[Yy]ou\'re|[Yy]ou\'ve|[Yy]ou\'ll|[Yy]ou\'d" +
          "|[Hh]e\'s|[Hh]e\'ll|[Hh]e\'d" + 
          "|[Ss]he\'s|[Ss]he\'ll|[Ss]he\'d" + 
          "|[Ii]t\'s|[Ii]t\'ll|[Ii]t\'d" + 
          "|[Tt]hey\'re|[Tt]hey\'ve|[Tt]hey\'ll|[Tt]hey\'d" + 
          "|(?:#{UB_ALNUM}+\'#{UB_ALNUM}+)" + 
          "|#{UB_ALNUM})"

        # unicolumn katakana (0x8e21-0x8e5f)
        UB_KATA = '(?:\x8e[\x21-\x5f])'

        # multibyte symbols, excluding macron("onbiki") 
        # and repeat("noma"):
        # 0xa1a1-0xa1b8, 0xa1ba-0xa1bb, 0xa1bd-0xa1fe, 
        # 0xa2a1-0xa2fe
        # macron is treated as a part of katakana 
        # (and also of hiragana, though it's not that likely.) 
        # Noma is treated as a part of kanji.
        # exception: 
        #   ノマ(々)       # repeat previous kanji
        #   仮名返し: ヽヾ # repeat previous hiragana
        #             ゝゞ # repeat previous katakana
        #             〃   # repeat previous element in chart/table
        # !! these exceptions above are not yet implemented !!!
        MB_SYMBOL = 
          '(?:(?:\xa1[\xa1-\xb8\xba-\xbb\xbd-\xfe])' + 
          '|(?:\xa2[\xa1-\xfe]))'

        # mb alphanumeric: 0xa3b0-0xa3ff
        MB_ALNUM  = '(?:\xa3[\xb0-\xff])'

        # mb hiragana: 0xa4a1-0xa4fe (+ 0xa1bc(=macron))
        MB_HIRA         = '(?:\xa4[\xa1-\xfe])'
        MB_HIRA_MACRON  = '(?:(?:\xa4[\xa1-\xfe])' + 
                          '|(?:\xa1\xbc))'

        # mb katakana: 0xa5a1-0xa5fe + 0xa1bc(=macron)
        MB_KATA     = '(?:(?:\xa5[\xa1-\xfe])|(?:\xa1\xbc))'

        # mb Greek: 0xa6a1-0xa6fe
        MB_GREEK    = '(?:\xa6[\xa1-\xfe])'
        # mb Cyrillic: 0xa7a1-0xa7fe
        MB_CYRILLIC = '(?:\xa7[\xa1-\xfe])'

        # mb box drawing symbol (=keisen): 0xa8a1-0xa8fe
        MB_BOXDRAW  = '(?:\xa8[\xa1-\xfe])'

        # mb undefined area (vendor dependent): 
        # 0xa9a1-0xacfe, 0xaea1-0xaffe
        MB_UNDEFINED  = '(?:(?:[\xa9-\xac][\xa1-\xfe])' + 
                        '|(?:[\xae-\xaf][\xa1-\xfe]))'

        # mb NEC-only symbol: 0xada1-0xadfe
        MB_SYMBOL_NEC = '(?:\xad[\xa1-\xfe])'

        # mb kanji: 0xb0a1-0xfefe, 0xa1b9 
        # (0xa1b9 = kanji repetition symbol, so called 
        # "Kuma" or "Noma")
        # (actually this area includes undefined/NEC-kanji area)
        MB_KANJI = '(?:' + 
                   '(?:[\xb0-\xfe][\xa1-\xfe])' + 
                   '|(?:\xa1\xb9)' + 
                   ')'

        WordPattern = Regexp.new(Japanese::word_pattern(self), 
                                 Regexp::MULTILINE, "e")

        def to_char()
          split(//e)
        end

        def to_word()
          scan(WordPattern)
        end

        def to_line()
        end

        def to_sentense()
        end

        def to_paragraph()
        end

        StringPlus.register_encoding(self)

      end

      module ShiftJIS

        LANG = "Japanese"
        ENC  = "Shift_JIS"

        # ASCII printable symbols 
        # (excluding hyphen ('-', 0x2d)):
        UB_SYMBOL = 
          '(?:' +
          '(?:[\x20-\x2c])' +  # 0x20-0x2f ( !"#$%&'()*+,-./)
          '|(?:[\x2e-\x2f])' +
          '|(?:[\x3a-\x40])' + # 0x3a-0x40 (:;<=>?@)
          '|(?:[\x5b-\x5e])' + # 0x5b-0x5e ([\]^)
          '|(?:\x60)' +        # 0x60      (`)
          '|(?:[\x7b-\x7e])' + # 0x7b-0x7e ({|}~)
          ')'

        # ASCII control characters
        UB_CONTROL = '(?:[\x00-\x1f])'

        # ASCII alphabet, number, and hyphen 
        # (so that good-bye becomes 1 word).
        UB_ALNUM = '(?:[0-9A-Za-z_\-])'
        UB_ALNUM_ABB = 
          "(?:Mr.|Mrs.|Ms.|Dr.|etc." + 
          "|I\'m|I\'ve|I\'ll|I\'d" + 
          "|[Ww]e\'re|[Ww]e\'ve|[Ww]e\'ll|[Ww]e\'d" + 
          "|[Yy]ou\'re|[Yy]ou\'ve|[Yy]ou\'ll|[Yy]ou\'d" +
          "|[Hh]e\'s|[Hh]e\'ll|[Hh]e\'d" + 
          "|[Ss]he\'s|[Ss]he\'ll|[Ss]he\'d" + 
          "|[Ii]t\'s|[Ii]t\'ll|[Ii]t\'d" + 
          "|[Tt]hey\'re|[Tt]hey\'ve|[Tt]hey\'ll|[Tt]hey\'d" + 
          "|(?:#{UB_ALNUM}+\'#{UB_ALNUM}+)" + 
          "|#{UB_ALNUM})"

        # SJIS unibyte katakana (0xa1-0xdf)
        UB_KATA = '(?:[\xa1-\xdf])'

        # multibyte symbol (excluding macron("onbiki") 
        # and repeat("noma")):
        # 0x8141-0x8157, 0x8159-0x815a, 0x815c-0x819e, 
        # 0x819f-0x81fc
        # macron is included in katakana (and hiragana 
        # when not bothering match), Noma in kanji.
        # exceptions: 
        #   ノマ(々)       # repeat previous kanji
        #   仮名返し: ヽヾ # repeat previous hiragana
        #             ゝゞ # repeat previous katakana
        #             〃   # repeat previous element in chart/table
        # !! these exceptions above are not yet implemented !!!
        MB_SYMBOL = '(?:\x81[\x41-\x57\x59-\x5a\x5c-\x9e\x9f-\xfc])'

        # mb alphabet and number: 0x824f-0x829e
        MB_ALNUM = '(?:\x82[\x4f-\x9e])'

        # mb hiragana: 0x829f-0x82ff (+ 0x815b(=macron))
        MB_HIRA  = '(?:\x82[\x9f-\xff])'
        MB_HIRA_MACRON = '(?:(?:\x82[\x9f-\xff])|(?:\x81\x5b))'

        # mb katakana: 0x8340-0x839e, including 
        # 0x815b(=macron, onbiki)
        MB_KATA = '(?:(?:\x83[\x40-\x9e])|(?:\x81\x5b))'

        # mb Greek: 0x839f-0x83d6
        MB_GREEK    = '(?:\x83[\x9f-\xd6])'
        # mb Cyrillic: 0x8440-0x8491
        MB_CYRILLIC = '(?:\x84[\x40-\x91])'

        # mb box drawing (=keisen): 0x849f-0x84be
        MB_BOXDRAW  = '(?:\x84[\x9f-\xbe])'

        # mb undefined area (vendor dependent): 
        # 0x8540-0x86fe, 0x879f-0x889c
        MB_UNDEFINED = '(?:' + 
                       '(?:\x85[\x40-\x9c])' + 
                       '|(?:\x86[\x40-\xfe])' +
                       '|(?:\x87[\x9f-\xfd)' + 
                       '|(?:\x88[\x40-\x9c])' + 
                       ')'

        # mb NEC-only symbol: 0x8740-0x879e
        MB_SYMBOL_NEC = '(?:\x87[\x40-\x9e])'

        # mb kanji: 0x889f-0xeffc, 0x8158
        # (0x8158 = "Noma", kanji repetition symbol)
        # (actually this area includes 
        #  undefined/NEC-kanji area)
        MB_KANJI = '(?:(?:\x88[\x9f-\xfc])' + 
                   '|(?:[\x89-\xef][\x00-\xff])' + 
                   '|(?:\x81\x58))'

        word_pattern = "#{UB_ALNUM_ABB}+ ?" + 
                       "|#{MB_KANJI}+#{MB_HIRA}+" + 
                       "|#{MB_KATA}+#{MB_HIRA}+" + 
                       "|#{MB_KANJI}+" + 
	               "|#{MB_KATA}+" + 
                       "|#{MB_HIRA_MACRON}+" + 
                       "|.+?"
        WordPattern = Regexp.new(word_pattern, 
                                 Regexp::MULTILINE, "s")

        def to_char()
          split(//s)
        end

        def to_word()
          scan(WordPattern)
        end

        def to_line()
        end

        def to_sentense()
        end

        def to_paragraph()
        end

        StringPlus.register_encoding(self)

      end

      module UTF8Ja

        LANG = "Japanese"
        ENC  = "UTF-8"

        def to_char()
          split(//u)
        end

        def to_word()
          raise "not implemented yet."
        end

        def to_line()
        end

        def to_sentense()
        end

        def to_paragraph()
        end

        StringPlus.register_encoding(self)

      end

    end  # end module Japanese

    module CR

      EOL = "\r"

      def to_line()
        scan(/.*?\r|.+/m)
      end

      StringPlus.register_eol(self)

    end

    module LF

      EOL = "\n"

      def to_line()
        scan(/.*?\n|.+/m)
      end

      StringPlus.register_eol(self)

    end

    module CRLF

      EOL = "\r\n"

      def to_line()
        scan(/.*?\r\n|.+/m)
      end

      StringPlus.register_eol(self)

    end

  end  # module StringPlus

  class Difference

    @resolution = nil # char, word, phrase, sentence, line, paragraph..
    # @body = nil     # format undecided...

    module Formatter

      def to_console()
      end

      def to_html2()
      end

      def to_xhtml()
      end

      def to_manued()
      end

      def to_docdiff()
      end

      def to_rtf()
      end

      def to_debug()
      end

    end  # module Formatter

  end  # class Difference

end  # module DocDiff

if $0 == __FILE__

end
