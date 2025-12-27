#!/usr/bin/ruby
# Character String module.
# To use, include to String, or extend String.
# 2003- Hisashi MORITA

class DocDiff
  module CharString
    Encodings = {}
    EOLChars = {} # End-of-line characters, such as CR, LF, CRLF.

    def initialize(string)
=begin unnecessary
#    @encoding = CharString.guess_encoding(string)
#    @eol     = CharString.guess_eol(string)
=end unnecessary
      super
    end

    def eol
      @eol
#     if @eol
#       @eol
#     else
#       @eol = CharString.guess_eol(self)
#       # raise "eol is not set.\n"
#     end
    end

    def eol=(e)
      @eol = e
      extend(EOLChars[@eol])
    end

    def eol_char
      if @eol_char
        @eol_char
      else
        nil
#       extend EOLChars[eol]
#       eol_char
      end
    end

    def debug
      case
      when @encoding == nil
        raise "@encoding is nil."
      when Encodings[@encoding] == nil
        raise "Encodings[@encoding(=#{@encoding})] is nil."
      when Encodings[@encoding].class != Module
        raise "Encodings[@encoding].class(=#{Encodings[@encoding].class}) is not a module."
      when @eol == nil
        raise "@eol is nil."
      when EOLChars[@eol] == nil
        raise "EOLChars[@eol(=#{@eol})] is nil."
      else
        # should I do some alert?
      end

      [
        "id: #{self.id}, class: #{self.class}, self: #{self}, ",
        "module: #{Encodings[@encoding]}, #{EOLChars[@eol]}",
      ].join
    end

    class << self
      def register_encoding(mod)
        Encodings[mod::Encoding] = mod
      end

      def register_eol(mod)
        EOLChars[mod::EOL] = mod
      end

      def guess_eol(string)
        # returns 'CR', 'LF', 'CRLF', 'UNKNOWN'(binary),
        # 'NONE'(1-line), or nil
        return nil if string == nil #=> nil (argument missing)

        bin_string = string.dup.force_encoding("ASCII-8BIT")
        eol_counts = {
          "CR"   => bin_string.scan(/(\r)(?!\n)/o).size,
          "LF"   => bin_string.scan(/(?:\A|[^\r])(\n)/o).size,
          "CRLF" => bin_string.scan(/(\r\n)/o).size,
        }
        eol_counts.delete_if { |_eol, count| count == 0 } # Remove missing EOL
        eols = eol_counts.keys
        eol_variety = eols.size # numbers of flavors found
        if eol_variety == 1     # Only one type of EOL found
          return eols[0]        #=> 'CR', 'LF', or 'CRLF'
        elsif eol_variety == 0  # No EOL found
          return "NONE"         #=> 'NONE' (might be 1-line file)
        else                    # Multiple types of EOL found
          return "UNKNOWN"      #=> 'UNKNOWN' (might be binary data)
        end
      end
    end

    # Note that some languages (like Japanese) do not have 'word' or 'phrase',
    # thus some of the following methods are not 'linguistically correct'.

    def count_byte
      split_to_byte.size
    end

    def count_char  # eol = 1 char
      split_to_char.size
    end

    def count_graph_char
      count_latin_graph_char + count_ja_graph_char
    end

    def count_blank_char
      count_latin_blank_char + count_ja_blank_char
    end

    def count_word
      split_to_word.size
    end

    def count_valid_word
      count_latin_valid_word + count_ja_valid_word
    end

    def count_line  # this is common to all encodings.
      split_to_line.size
    end

    def count_empty_line
      split_to_line.count { |line| /^(?:#{eol_char})|^$/m.match(line) }
    end

    # for Ruby-1.9
    def encoding
      String.new(self).encoding.to_s
    end

    def encoding=(cs)
      force_encoding(cs) if self
    end

    class << self
      def guess_encoding(string)
        if string
          string.encoding.to_s
        else
          nil
        end
      end
    end

    def split_to_byte
      encode("ASCII-8BIT").scan(/./nm)
    end

    def split_to_char
      if eol_char # sometimes string has no end-of-line char
        re = Regexp.new("(?:#{eol_char})|(?:.)", Regexp::MULTILINE)
        encode("UTF-8").scan(re).map { |e| e.encode(self.encoding) }
      else        # it seems that no EOL module was extended...
        re = Regexp.new("(?:.)", Regexp::MULTILINE)
        encode("UTF-8").scan(re).map { |e| e.encode(self.encoding) }
      end
    end

    def count_latin_graph_char
      re = Regexp.new("[#{Encodings["UTF-8"]::GRAPH}]", Regexp::MULTILINE)
      encode("UTF-8").scan(re).size
    end

    def count_ja_graph_char
      re = Regexp.new("[#{Encodings["UTF-8"]::JA_GRAPH}]", Regexp::MULTILINE)
      encode("UTF-8").scan(re).size
    end

    def count_latin_blank_char
      re = Regexp.new("[#{Encodings["UTF-8"]::BLANK}]", Regexp::MULTILINE)
      encode("UTF-8").scan(re).size
    end

    def count_ja_blank_char
      re = Regexp.new("[#{Encodings["UTF-8"]::JA_BLANK}]", Regexp::MULTILINE)
      encode("UTF-8").scan(re).size
    end

    def split_to_word
      re = Regexp.new(Encodings["UTF-8"]::WORD_REGEXP_SRC, Regexp::MULTILINE)
      encode("UTF-8").scan(re).map { |e| e.encode(self.encoding) }
    end

    def count_latin_word
      re = Regexp.new("[#{Encodings["UTF-8"]::PRINT}]", Regexp::MULTILINE)
      split_to_word.count { |word| re.match(word.encode("UTF-8")) }
    end

    def count_ja_word
      re = Regexp.new("[#{Encodings["UTF-8"]::JA_PRINT}]", Regexp::MULTILINE)
      split_to_word.count { |word| re.match(word.encode("UTF-8")) }
    end

    def count_latin_valid_word
      re = Regexp.new("[#{Encodings["UTF-8"]::ALNUM}]", Regexp::MULTILINE)
      split_to_word.count { |word| re.match(word.encode("UTF-8")) }
    end

    def count_ja_valid_word
      re = Regexp.new("[#{Encodings["UTF-8"]::JA_GRAPH}]", Regexp::MULTILINE)
      split_to_word.count { |word| re.match(word.encode("UTF-8")) }
    end

    def split_to_line
      raise <<~EOS.chomp unless EOLChars[eol]
        EOLChars[eol] is #{EOLChars[eol].inspect}: eol not specified or auto-detection failed.
      EOS

      if defined? eol_char
        re = Regexp.new(".*?#{eol_char}|.+", Regexp::MULTILINE)
        encode("UTF-8").scan(re).map { |e| e.encode(self.encoding) }
      else
        re = Regexp.new(".+", Regexp::MULTILINE)
        encode("UTF-8").scan(re).map { |e| e.encode(self.encoding) }
      end
    end

    def count_graph_line
      graph = (Encodings["UTF-8"]::GRAPH + Encodings["UTF-8"]::JA_GRAPH).chars.uniq.join
      re = Regexp.new("[#{Regexp.quote(graph)}]", Regexp::MULTILINE)
      split_to_line.count { |line| re.match(line.encode("UTF-8")) }
    end

    def count_blank_line
      blank = (Encodings["UTF-8"]::BLANK + Encodings["UTF-8"]::JA_BLANK).chars.uniq.join
      re = Regexp.new("^[#{blank}]+(?:#{eol_char})?", Regexp::MULTILINE)
      split_to_line.count { |line| re.match(line.encode("UTF-8")) }
    end

    # load encoding modules
    require "docdiff/encoding/en_ascii"
    require "docdiff/encoding/ja_eucjp"
    require "docdiff/encoding/ja_sjis"
    require "docdiff/encoding/ja_utf8"
    alias_method :to_bytes, :split_to_byte
    alias_method :to_chars, :split_to_char
    alias_method :to_words, :split_to_word
    alias_method :to_lines, :split_to_line

    module CR
      EOL = "CR"

      def eol_char
        "\r"
      end

      CharString.register_eol(self)
    end

    module LF
      EOL = "LF"

      def eol_char
        "\n"
      end

      CharString.register_eol(self)
    end

    module CRLF
      EOL = "CRLF"

      def eol_char
        "\r\n"
      end

      CharString.register_eol(self)
    end

    module NoEOL
      EOL = "NONE"

      def eol_char
        nil
      end

      CharString.register_eol(self)
    end
  end # module CharString
end # class DocDiff

# class String
#   include CharString
# end
