# Document class, a part of DocDiff
# 2004-01-14.. Hisashi MORITA

require 'charstring'
require 'difference'

class Document < String

  include CharString

  def compare_by_line_with(other_document)
    Difference.new(self.split_to_line, other_document.split_to_line)
  end

  def compare_by_word_with(other_document)
    lines = Difference.new(self.split_to_line, other_document.split_to_line)
    words = Difference.new
    lines.each{|line|
      if line.first == :change_elt
        before_change = Document.new(line[1].to_s)
        after_change  = Document.new(line[2].to_s)
        Difference.new(before_change.split_to_word, after_change.split_to_word).each{|word|
          words << word
        }
      else  # :common_elt_elt, :del_elt, or :add_elt
        words << line
      end
    }
    words
  end

  # i know this implementation of recursion is so lame...
  def compare_by_char_with(other_document)
    lines = Difference.new(self.split_to_line, other_document.split_to_line)
    lines_and_words = Difference.new
    lines.each{|line|
      if line.first == :change_elt
        before_change = Document.new(line[1].to_s)
        after_change  = Document.new(line[2].to_s)
        Difference.new(before_change.split_to_word, after_change.split_to_word).each{|word|
          lines_and_words << word
        }
      else  # :common_elt_elt, :del_elt, or :add_elt
        lines_and_words << line
      end
    }
    lines_words_and_chars = Difference.new
    lines_and_words.each{|line_or_word|
      if line_or_word.first == :change_elt
        before_change = Document.new(line_or_word[1].to_s)
        after_change  = Document.new(line_or_word[2].to_s)
        Difference.new(before_change.split_to_char, after_change.split_to_char).each{|char|
          lines_words_and_chars << char
        }
      else  # :common_elt_elt, :del_elt, or :add_elt
        lines_words_and_chars << line_or_word
      end
    }
    lines_words_and_chars
  end

end  # class Document
