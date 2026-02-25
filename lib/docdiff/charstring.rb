#!/usr/bin/ruby
# Character String module.
# To use, include to String, or extend String.
# 2003- Hisashi MORITA

class DocDiff
  module CharString
    Encodings = {}
    EOLChars = {} # End-of-line characters, such as CR, LF, CRLF.

    def initialize(string)
      # unnecessary
      # @encoding = CharString.guess_encoding(string)
      # @eol      = CharString.guess_eol(string)
      super
    end

    def eol
      @eol
      # if @eol
      #   @eol
      # else
      #   @eol = CharString.guess_eol(self)
      #   # raise "eol is not set.\n"
      # end
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
        # extend EOLChars[eol]
        # eol_char
      end
    end

    def debug
      if @encoding.nil?
        raise "@encoding is nil."
      elsif Encodings[@encoding].nil?
        raise "Encodings[@encoding(=#{@encoding})] is nil."
      elsif Encodings[@encoding].class != Module
        raise "Encodings[@encoding].class(=#{Encodings[@encoding].class}) is not a module."
      elsif @eol.nil?
        raise "@eol is nil."
      elsif EOLChars[@eol].nil?
        raise "EOLChars[@eol(=#{@eol})] is nil."
      else
        # should I do some alert?
      end

      [
        "id: #{id}, class: #{self.class}, self: #{self}, ",
        "module: #{Encodings[@encoding]}, #{EOLChars[@eol]}",
      ].join
    end

    class << self
      def register_encoding(mod)
        Encodings[mod::ENCODING] = mod
      end

      def register_eol(mod)
        EOLChars[mod::EOL] = mod
      end

      def guess_eol(string)
        # returns 'CR', 'LF', 'CRLF', 'UNKNOWN'(binary),
        # 'NONE'(1-line), or nil
        return if string.nil? #=> nil (argument missing)

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
          eols[0]               #=> 'CR', 'LF', or 'CRLF'
        elsif eol_variety == 0  # No EOL found
          "NONE"                #=> 'NONE' (might be 1-line file)
        else                    # Multiple types of EOL found
          "UNKNOWN"             #=> 'UNKNOWN' (might be binary data)
        end
      end
    end

    # Note that some languages (like Japanese) do not have 'word' or 'phrase',
    # thus some of the following methods are not 'linguistically correct'.

    def count_bytes
      to_bytes.size
    end

    def count_chars  # eol = 1 char
      to_chars.size
    end

    def count_graph_chars
      count_latin_graph_chars + count_ja_graph_chars
    end

    def count_blank_chars
      count_latin_blank_chars + count_ja_blank_chars
    end

    def count_words
      to_words.size
    end

    def count_valid_words
      count_latin_valid_words + count_ja_valid_words
    end

    def count_lines  # this is common to all encodings.
      to_lines.size
    end

    def count_empty_lines
      to_lines.count { |line| /^(?:#{eol_char})|^$/m.match(line) }
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
        end
      end
    end

    def to_bytes
      encode("ASCII-8BIT").scan(/./nm)
    end

    def to_chars
      re =
        if eol_char # sometimes string has no end-of-line char
          Regexp.new("(?:#{eol_char})|(?:.)", Regexp::MULTILINE)
        else        # it seems that no EOL module was extended...
          Regexp.new("(?:.)", Regexp::MULTILINE)
        end
      encode("UTF-8").scan(re).map { |e| e.encode(encoding) }
    end

    def count_latin_graph_chars
      re = Regexp.new("[#{Encodings["UTF-8"]::GRAPH}]", Regexp::MULTILINE)
      encode("UTF-8").scan(re).size
    end

    def count_ja_graph_chars
      re = Regexp.new("[#{Encodings["UTF-8"]::JA_GRAPH}]", Regexp::MULTILINE)
      encode("UTF-8").scan(re).size
    end

    def count_latin_blank_chars
      re = Regexp.new("[#{Encodings["UTF-8"]::BLANK}]", Regexp::MULTILINE)
      encode("UTF-8").scan(re).size
    end

    def count_ja_blank_chars
      re = Regexp.new("[#{Encodings["UTF-8"]::JA_BLANK}]", Regexp::MULTILINE)
      encode("UTF-8").scan(re).size
    end

    def to_words
      re = Regexp.new(Encodings["UTF-8"]::WORD_REGEXP_SRC, Regexp::MULTILINE)
      encode("UTF-8").scan(re).map { |e| e.encode(encoding) }
    end

    def count_latin_words
      re = Regexp.new("[#{Encodings["UTF-8"]::PRINT}]", Regexp::MULTILINE)
      to_words.count { |word| re.match(word.encode("UTF-8")) }
    end

    def count_ja_words
      re = Regexp.new("[#{Encodings["UTF-8"]::JA_PRINT}]", Regexp::MULTILINE)
      to_words.count { |word| re.match(word.encode("UTF-8")) }
    end

    def count_latin_valid_words
      re = Regexp.new("[#{Encodings["UTF-8"]::ALNUM}]", Regexp::MULTILINE)
      to_words.count { |word| re.match(word.encode("UTF-8")) }
    end

    def count_ja_valid_words
      re = Regexp.new("[#{Encodings["UTF-8"]::JA_GRAPH}]", Regexp::MULTILINE)
      to_words.count { |word| re.match(word.encode("UTF-8")) }
    end

    def to_lines
      raise <<~EOS.chomp unless EOLChars[eol]
        EOLChars[eol] is #{EOLChars[eol].inspect}: eol not specified or auto-detection failed.
      EOS

      re =
        if defined? eol_char
          Regexp.new(".*?#{eol_char}|.+", Regexp::MULTILINE)
        else
          Regexp.new(".+", Regexp::MULTILINE)
        end
      encode("UTF-8").scan(re).map { |e| e.encode(encoding) }
    end

    def count_graph_lines
      graph = (Encodings["UTF-8"]::GRAPH + Encodings["UTF-8"]::JA_GRAPH).chars.uniq.join
      re = Regexp.new("[#{Regexp.quote(graph)}]", Regexp::MULTILINE)
      to_lines.count { |line| re.match(line.encode("UTF-8")) }
    end

    def count_blank_lines
      blank = (Encodings["UTF-8"]::BLANK + Encodings["UTF-8"]::JA_BLANK).chars.uniq.join
      re = Regexp.new("^[#{blank}]+(?:#{eol_char})?", Regexp::MULTILINE)
      to_lines.count { |line| re.match(line.encode("UTF-8")) }
    end

    # load encoding modules
    require "docdiff/encoding/en_ascii"
    require "docdiff/encoding/ja_eucjp"
    require "docdiff/encoding/ja_sjis"
    require "docdiff/encoding/ja_utf8"

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
  end
end

# class String
#   include CharString
# end
