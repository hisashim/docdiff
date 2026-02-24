# Document class, a part of DocDiff
# 2004-01-14.. Hisashi MORITA

require "docdiff/charstring"

class EncodingDetectionFailure < StandardError
end

class EOLDetectionFailure < StandardError
end

class DocDiff
  class Document
    def initialize(str, enc = nil, e = nil)
      @body = str
      @body.extend(CharString)
      if enc
        @body.encoding = enc
      elsif !@body.encoding
        guessed_encoding = CharString.guess_encoding(str)
        if guessed_encoding == "UNKNOWN"
          raise EncodingDetectionFailure, "encoding not specified, and auto detection failed."
        # @body.encoding = 'ASCII' # default to ASCII <= BAD!
        else
          @body.encoding = guessed_encoding
        end
      end
      if e
        @body.eol = e
      else
        guessed_eol = CharString.guess_eol(str)
        if guessed_eol == "UNKNOWN"
          raise EOLDetectionFailure, "eol not specified, and auto detection failed."
        # @body.eol = 'LF' # default to LF
        else
          @body.eol = guessed_eol
        end
      end
    end

    def encoding
      @body.encoding
    end

    def encoding=(cs)
      @body.encoding = cs
    end

    def eol
      @body.eol
    end

    def eol=(eolstr)
      @body.eol = eolstr
    end

    def split_to_lines
      @body.split_to_lines
    end

    def split_to_words
      @body.split_to_words
    end

    def split_to_chars
      @body.split_to_chars
    end

    def split_to_bytes
      @body.split_to_bytes
    end

    def count_lines
      @body.count_lines
    end

    def count_blank_lines
      @body.count_blank_lines
    end

    def count_empty_lines
      @body.count_empty_lines
    end

    def count_graph_lines
      @body.count_graph_lines
    end

    def count_words
      @body.count_words
    end

    def count_latin_words
      @body.count_latin_words
    end

    def count_ja_words
      @body.count_ja_words
    end

    def count_valid_words
      @body.count_valid_words
    end

    def count_latin_valid_words
      @body.count_latin_valid_words
    end

    def count_ja_valid_words
      @body.count_ja_valid_words
    end

    def count_chars
      @body.count_chars
    end

    def count_blank_chars
      @body.count_blank_chars
    end

    def count_graph_chars
      @body.count_graph_chars
    end

    def count_latin_blank_chars
      @body.count_latin_blank_chars
    end

    def count_latin_graph_chars
      @body.count_latin_graph_chars
    end

    def count_ja_blank_chars
      @body.count_ja_blank_chars
    end

    def count_ja_graph_chars
      @body.count_ja_graph_chars
    end

    def count_bytes
      @body.count_bytes
    end

    def eol_char
      @body.eol_char
    end
  end
end
