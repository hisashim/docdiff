#!/usr/bin/ruby
# Character String module.
# To use, include to String, or extend String.
# 2003- Hisashi MORITA

module CharString

  CodeSets = Hash.new
  EOLChars = Hash.new  # End-of-line characters, such as CR, LF, CRLF.

  def initialize(string)
=begin unnecessary
#    @codeset = CharString.guess_codeset(string)
#    @eol     = CharString.guess_eol(string)
=end unnecessary
    super
  end

  def codeset()
    if @codeset
      @codeset
    else
      @codeset = CharString.guess_codeset(self)
      # raise "codeset is not set.\n"
    end
  end

  def codeset=(cs)
    @codeset = cs
    extend CodeSets[@codeset]  # ; p "Hey, I extended #{CodeSets[@codeset]}!"
  end

  def eol()
    if @eol
      @eol
    else
      @eol = CharString.guess_eol(self)
      # raise "eol is not set.\n"
    end
  end

  def eol=(e)
    @eol = e
    extend EOLChars[@eol]
  end

  def eol_char()
    if @eol_char
      @eol_char
    else
      extend EOLChars[eol]
      eol_char
    end
  end

  def debug()
    case
    when @codeset  == nil
      raise "@codeset is nil."
    when CodeSets[@codeset] == nil
      raise "CodeSets[@codeset(=#{@codeset})] is nil."
    when CodeSets[@codeset].class != Module
      raise "CodeSets[@codeset].class(=#{CodeSets[@codeset].class}) is not a module."
    when @eol == nil
      raise "@eol is nil."
    when EOLChars[@eol] == nil
      raise "EOLChars[@eol(=#{@eol})] is nil."
    else
      # should I do some alert?
    end
    ["id: #{self.id}, class: #{self.class}, self: #{self}, ", 
     "module: #{CodeSets[@codeset]}, #{EOLChars[@eol]}"].join
  end

  def CharString.register_codeset(mod)
    CodeSets[mod::CodeSet] = mod
  end

  def CharString.register_eol(mod)
    EOLChars[mod::EOL] = mod
  end

  # returns 'JIS', 'EUC-JP', 'Shift_JIS', 'UTF-8', or 'UNKNOWN'
  def CharString.guess_codeset(string, sample_length = 65536)
    return nil if string == nil
    sample = string[0 .. (sample_length - 1)]

    ascii_pat = '[\x00-\x7f]'
    jis_pat   = ['(?:(?:\x1b\x28\x42)', 
                 '|(?:\x1b\x28\x4a)', 
                 '|(?:\x1b\x28\x49)', 
                 '|(?:\x1b\x24\x40)', 
                 '|(?:\x1b\x24\x42)', 
                 '|(?:\x1b\x24\x44))'].join
    eucjp_pat = ['(?:(?:[\x00-\x1f\x7f])', 
                 '|(?:[\x20-\x7e])', 
                 '|(?:\x8e[\xa1-\xdf])', 
                 '|(?:[\xa1-\xfe][\xa1-\xfe])', 
                 '|(?:\x8f[\xa1-\xfe][\xa1-\xfe]))'].join
    sjis_pat  = ['(?:(?:[\x00-\x1f\x7f])', 
                 '|(?:[\x20-\x7e])', 
                 '|(?:[\xa1-\xdf])', 
                 '|(?:[\x81-\x9f][\x40-\x7e])', 
                 '|(?:[\xe0-\xef][\x80-\xfc]))'].join
    utf8_pat  = ['(?:(?:[\x00-\x7f])', 
                 '|(?:[\xc0-\xdf][\x80-\xbf])', 
                 '|(?:[\xe0-\xef][\x80-\xbf][\x80-\xbf])', 
                 '|(?:[\xf0-\xf7][\x80-\xbf][\x80-\xbf][\x80-\xbf]))'].join

    ascii_match_length = sample.scan(/#{ascii_pat}/on).join.length
    jis_escseq_count   = sample.scan(/#{jis_pat}/on).size
    eucjp_match_length = sample.scan(/#{eucjp_pat}/no).join.length
    sjis_match_length  = sample.scan(/#{sjis_pat}/no).join.length
    utf8_match_length  = sample.scan(/#{utf8_pat}/no).join.length

    case
    when 0 < jis_escseq_count                 # JIS escape sequense found
      guessed_codeset = 'JIS'
    when ascii_match_length == sample.length  # every char is ASCII (but not JIS)
      guessed_codeset = 'ASCII'
    else
      case
      when eucjp_match_length < (sample.length / 2) && 
           sjis_match_length  < (sample.length / 2) && 
           utf8_match_length  < (sample.length / 2)
        guessed_codeset = 'UNKNOWN'  # either codeset did not match long enough
      when (eucjp_match_length < utf8_match_length) && 
           (sjis_match_length < utf8_match_length)
        guessed_codeset = 'UTF-8'
      when (eucjp_match_length < sjis_match_length) && 
           (utf8_match_length < sjis_match_length)
        guessed_codeset = 'Shift_JIS'
      when (sjis_match_length < eucjp_match_length) && 
           (utf8_match_length < eucjp_match_length)
        guessed_codeset = 'EUC-JP'
      else
        guessed_codeset = 'UNKNOWN'  # cannot guess at all
      end
    end
    return guessed_codeset
  end

  def CharString.guess_eol(string, sample_length = 65536)
    # returns 'CR', 'LF', 'CRLF', 'UNKNOWN'(binary), 
    # 'NONE'(1-line), or nil
    return nil if string == nil  #=> nil (argument missing)
    sample = string[0 .. (sample_length - 1)]
    eol_counts = {'CR'   => sample.scan(/(\r)(?!\n)/no).size,
                  'LF'   => sample.scan(/(?:\A|[^\r])(\n)/no).size,
                  'CRLF' => sample.scan(/(\r\n)/no).size}
    eol_counts.delete_if{|eol, count| count == 0}  # Remove missing EOL
    eols = eol_counts.keys
    eol_variety = eols.size  # numbers of flavors found
    if eol_variety == 1          # Only one type of EOL found
      return eols[0]         #=> 'CR', 'LF', or 'CRLF'
    elsif eol_variety == 0       # No EOL found
      return 'NONE'              #=> 'NONE' (might be 1-line file)
    else                         # Multiple types of EOL found
      return 'UNKNOWN'           #=> 'UNKNOWN' (might be binary data)
    end
  end

  # Note that some languages (like Japanese) do not have 'word' or 'phrase', 
  # thus some of the following methods are not 'linguistically correct'.

  def split_to_byte()
    scan(/./nm)
  end

  def count_byte()
    split_to_byte().size
  end

  def split_to_char()
    raise "CodeSets[codeset] is #{CodeSets[codeset].inspect}: codeset not specified or auto-detection failed." unless CodeSets[codeset]
    raise "EOLChars[eol] is #{EOLChars[eol].inspect}: eol not specified or auto-detection failed." unless EOLChars[eol]
    if defined? eol_char  # sometimes string has no end-of-line char
      scan(Regexp.new("(?:#{eol_char})|(?:.)", 
                      Regexp::MULTILINE, 
                      codeset.sub(/ASCII/i, 'none'))
      )
    else                  # it seems that no EOL module was extended...
      scan(Regexp.new("(?:.)", 
                      Regexp::MULTILINE, 
                      codeset.sub(/ASCII/i, 'none'))
      )
    end
  end

  def count_char()  # eol = 1 char
    split_to_char().size
  end

  def count_latin_graph_char()
    raise "CodeSets[codeset] is #{CodeSets[codeset].inspect}: codeset not specified or auto-detection failed." unless CodeSets[codeset]
    raise "EOLChars[eol] is #{EOLChars[eol].inspect}: eol not specified or auto-detection failed." unless EOLChars[eol]
    scan(Regexp.new("[#{CodeSets[codeset]::GRAPH}]", 
                    Regexp::MULTILINE, 
                    codeset.sub(/ASCII/i, 'none'))
    ).size
  end

  def count_ja_graph_char()
    raise "CodeSets[codeset] is #{CodeSets[codeset].inspect}: codeset not specified or auto-detection failed." unless CodeSets[codeset]
    raise "EOLChars[eol] is #{EOLChars[eol].inspect}: eol not specified or auto-detection failed." unless EOLChars[eol]
    scan(Regexp.new("[#{CodeSets[codeset]::JA_GRAPH}]", 
                    Regexp::MULTILINE, 
                    codeset.sub(/ASCII/i, 'none'))
    ).size
  end

  def count_graph_char()
    count_latin_graph_char() + count_ja_graph_char()
  end

  def count_latin_blank_char()
    scan(Regexp.new("[#{CodeSets[codeset]::BLANK}]", 
                    Regexp::MULTILINE, 
                    codeset.sub(/ASCII/i, 'none'))
    ).size
  end

  def count_ja_blank_char()
    scan(Regexp.new("[#{CodeSets[codeset]::JA_BLANK}]", 
                    Regexp::MULTILINE, 
                    codeset.sub(/ASCII/i, 'none'))
    ).size
  end

  def count_blank_char()
    count_latin_blank_char() + count_ja_blank_char()
  end

  def split_to_word()
    raise "CodeSets[codeset] is #{CodeSets[codeset].inspect}: codeset not specified or auto-detection failed." unless CodeSets[codeset]
    raise "EOLChars[eol] is #{EOLChars[eol].inspect}: eol not specified or auto-detection failed." unless EOLChars[eol]
    scan(Regexp.new(CodeSets[codeset]::WORD_REGEXP_SRC, 
                    Regexp::MULTILINE, 
                    codeset.sub(/ASCII/i, 'none'))
    )
  end

  def count_word()
    split_to_word().size
  end

  def count_latin_word()
    split_to_word.collect{|word|
      word if Regexp.new("[#{CodeSets[codeset]::PRINT}]", 
                         Regexp::MULTILINE, 
                         codeset.sub(/ASCII/i, 'none')).match word
    }.compact.size
  end

  def count_ja_word()
    split_to_word.collect{|word|
      word if Regexp.new("[#{CodeSets[codeset]::JA_PRINT}]", 
                         Regexp::MULTILINE, 
                         codeset.sub(/ASCII/i, 'none')).match word
    }.compact.size
  end

  def count_latin_valid_word()
    split_to_word.collect{|word|
      word if Regexp.new("[#{CodeSets[codeset]::ALNUM}]", 
                         Regexp::MULTILINE, 
                         codeset.sub(/ASCII/i, 'none')).match word
    }.compact.size
  end

  def count_ja_valid_word()
    split_to_word.collect{|word|
      word if Regexp.new("[#{CodeSets[codeset]::JA_GRAPH}]", 
                         Regexp::MULTILINE, 
                         codeset.sub(/ASCII/i, 'none')).match word
    }.compact.size
  end

  def count_valid_word()
    count_latin_valid_word() + count_ja_valid_word()
  end

  def split_to_line()
#     scan(Regexp.new(".*?#{eol_char}|.+", 
#                     Regexp::MULTILINE, 
#                     codeset.sub(/ASCII/i, 'none'))
#     )
    raise "CodeSets[codeset] is #{CodeSets[codeset].inspect}: codeset not specified or auto-detection failed." unless CodeSets[codeset]
    raise "EOLChars[eol] is #{EOLChars[eol].inspect}: eol not specified or auto-detection failed." unless EOLChars[eol]
    if defined? eol_char
      scan(Regexp.new(".*?#{eol_char}|.+", 
                      Regexp::MULTILINE, 
                      codeset.sub(/ASCII/i, 'none'))
      )
    else
      scan(Regexp.new(".+", 
                      Regexp::MULTILINE, 
                      codeset.sub(/ASCII/i, 'none'))
      )
    end
  end

  def count_line()  # this is common to all encodings.
    split_to_line.size
  end

  def count_graph_line()
    split_to_line.collect{|line|
      line if Regexp.new("[#{CodeSets[codeset]::GRAPH}" + 
                         "#{CodeSets[codeset]::JA_GRAPH}]", 
                         Regexp::MULTILINE, 
                         codeset.sub(/ASCII/, 'none')).match line
    }.compact.size
  end

  def count_empty_line()
    split_to_line.collect{|line|
      line if /^(?:#{eol_char})|^$/em.match line
    }.compact.size
  end

  def count_blank_line()
    split_to_line.collect{|line|
      line if Regexp.new("^[#{CodeSets[codeset]::BLANK}" + 
                         "#{CodeSets[codeset]::JA_BLANK}]+(?:#{eol_char})?", 
                         Regexp::MULTILINE, 
                         codeset.sub(/ASCII/, 'none')).match line
    }.compact.size
  end

  # load encoding modules
  require 'encoding/en_ascii'
  require 'encoding/ja_eucjp'
  require 'encoding/ja_sjis'
  require 'encoding/ja_utf8'

  module CR
    EOL = 'CR'

    def eol_char()
      "\r"
    end

    CharString.register_eol(self)
  end

  module LF
    EOL = 'LF'

    def eol_char()
      "\n"
    end

    CharString.register_eol(self)
  end

  module CRLF
    EOL = 'CRLF'

    def eol_char()
      "\r\n"
    end

    CharString.register_eol(self)
  end

  module NoEOL
    EOL = 'NONE'
    def eol_char()
      nil
    end

    CharString.register_eol(self)
  end

end  # module CharString
