#!/usr/bin/ruby
# DocDiff 0.3
# 2002-06-27 Thu ... 2003-03-25 Mon ...
# Hisashi MORITA
# These scripts are distributed under the same license as Ruby's.
# requirement: Ruby (> 1.6), diff library by akr (included in Ruby/CVS),
#              Uconv by Yoshidam, NKF (for unit-testing)

require 'difference'
require 'document'

class DocDiff

  APP_VERSION = '0.3.0'
  COPYRIGHT = 'Copyleft 2002-2003 Hisashi MORITA'
  # USAGE

  # configuration
  # priority: default < ~/.docdiff < command line option
  #
  # command line options (draft)
  #
  # --version
  # --license
  # --help  -h
  # --debug
  ## --verbose
  #
  # --resolution=<unit>  --granularity
  #   <unit>: char | word | line
  #
  ## --cache= auto | on | off
  ## --cachedir= auto | <path>
  ## --conffile= auto | <path>
  #
  ### --input-type= text | html | xml
  ## --input-language= English | Japanese
  ## --input-encoding= auto | ASCII | EUC-JP | Shift_JIS | UTF-8
  ## --input-eol= auto | LF | CR | CRLF
  #
  ### --analysis= none | simple | complex
  #
  ## --detail= all | summary | digest
  ## --show-stat=off|on
  ## --show-document=on|off
  #
  ## --context=<integer><unit>,<integer><unit>
  ##   <unit>: char | word | line
  #
  ### --show-unified
  ### --show-source-only
  ### --show-target-only
  ### --show-common=on|off
  ### --show-removed=on|off
  ### --show-added=on|off
  #
  # --output-type= docdiff | tty | html | xhtml | manued
  ## --output-encoding= auto | ASCII | EUC-JP | Shift_JIS | UTF-8
  ## --output-eol= auto | original | system | LF | CR | CRLF
  #
  ## --tag-common="<>,</>"
  ## --tag-removed="<->,</->"  --tag-deleted
  ## --tag-added="<+>,</+>"    --tag-inserted

  def compare_by_line(doc1, doc2)
    Difference.new(doc1.split_to_line, doc2.split_to_line)
  end

  def compare_by_word(doc1, doc2)
    lines = Difference.new(doc1.split_to_line, doc2.split_to_line)
    words = Difference.new
    lines.each{|line|
      if line.first == :change_elt
        before_change = Document.new(line[1].to_s)
        before_change.encoding = doc1.encoding
        before_change.eol = doc1.eol
        after_change  = Document.new(line[2].to_s)
        after_change.encoding = doc2.encoding
        after_change.eol = doc2.eol
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
  def compare_by_char(doc1, doc2)
    lines = Difference.new(doc1.split_to_line, doc2.split_to_line)
    lines_and_words = Difference.new
    lines.each{|line|
      if line.first == :change_elt
        before_change = Document.new(line[1].to_s)
        before_change.encoding = doc1.encoding
        before_change.eol = doc1.eol
        after_change  = Document.new(line[2].to_s)
        after_change.encoding = doc2.encoding
        after_change.eol = doc2.eol
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
        before_change.encoding = doc1.encoding
        before_change.eol = doc1.eol
        after_change  = Document.new(line_or_word[2].to_s)
        after_change.encoding = doc2.encoding
        after_change.eol = doc2.eol
        Difference.new(before_change.split_to_char, after_change.split_to_char).each{|char|
          lines_words_and_chars << char
        }
      else  # :common_elt_elt, :del_elt, or :add_elt
        lines_words_and_chars << line_or_word
      end
    }
    lines_words_and_chars
  end

end  # class DocDiff

if $0 == __FILE__
#  configuration = DocDiff::Configuration.new
#  docdiff = DocDiff.new(configuration)
  docdiff = DocDiff.new()
  doc1 = doc2 = nil
  File.open(ARGV[0], "r"){|f| doc1 = Document.new(f.read)}
  File.open(ARGV[0], "r"){|f| doc2 = Document.new(f.read)}
  p doc1.split_to_line
  p doc1.split_to_line
#  p docdiff.compare_by_word(doc1, doc2)
end
