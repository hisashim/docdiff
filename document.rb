# Document class, a part of DocDiff
# 2004-01-14.. Hisashi MORITA

require 'charstring'
require 'difference'

class Document

  def initialize(str)
    @body = str
    @body.extend CharString
  end

  def codeset()
    @body.codeset
  end

  def codeset=(cs)
    @body.codeset = cs
  end

  def eol()
    @body.eol
  end

  def eol=(eolstr)
    @body.eol = eolstr
  end

  def split_to_line()
    @body.split_to_line
  end

  def split_to_word()
    @body.split_to_word
  end

  def split_to_char()
    @body.split_to_char
  end

#  def eol_char()
#    @body.eol_char
#  end

end  # class Document
