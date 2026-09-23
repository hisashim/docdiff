# Document class, a part of DocDiff
# 2004-01-14.. Hisashi MORITA

require "docdiff/charstring"

class DocDiff
  class Document
    class EncodingDetectionFailure < StandardError; end
    class EOLDetectionFailure < StandardError; end

    def initialize(string, encoding = nil, eol = nil, file_name = nil)
      @body = string
      @body.extend(CharString)

      if encoding
        @body.encoding = encoding
      elsif !@body.encoding
        guessed_encoding = CharString.guess_encoding(string)
        if guessed_encoding == "UNKNOWN"
          raise EncodingDetectionFailure, <<-EOS
            Encoding not specified, and auto detection failed
          EOS
          # @body.encoding = 'ASCII' # default to ASCII <= BAD!
        else
          @body.encoding = guessed_encoding
        end
      end

      if eol
        @body.eol = eol
      else
        guessed_eol = CharString.guess_eol(string)
        if guessed_eol == "UNKNOWN"
          raise EOLDetectionFailure, <<-EOS
            Eol not specified, and auto detection failed
          EOS
          # @body.eol = 'LF' # default to LF
        else
          @body.eol = guessed_eol
        end
      end

      @file_name = file_name
    end

    attr_reader :file_name

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

    def to_lines
      @body.to_lines
    end

    def to_words
      @body.to_words
    end

    def to_chars
      @body.to_chars
    end

    def to_bytes
      @body.to_bytes
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
