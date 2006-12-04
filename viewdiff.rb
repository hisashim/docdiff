#!/usr/bin/ruby
# 2005-08-29..xx-xx-xx Hisashi Morita

require 'docdiff/difference'
require 'docdiff/document'
require 'docdiff/view'
require 'docdiff/charstring'

require "tempfile"

# $KCODE="e"

class String
  def to_lines
    scan(Regexp.new("(?:.*(?:\r\n|\r|\n|\z))", Regexp::MULTILINE))
  end
end

class DiffFile < Array

  def initialize(src)
    src.extend(CharString)
    src.encoding = CharString.guess_encoding(src)
    src.eol = CharString.guess_eol(src)
    @src = src
  end
  attr_accessor :src

  def guess_diff_type(text)
    case
    when (/^[<>] /m).match(text)  then return "classic"
    when (/^[-+!] /m).match(text) then return "context"
    when (/^[-+]/m).match(text)   then return "unified"
    else
      raise "unknown diff format: #{text[0..256].inspect}..."
    end
  end

  def anatomize
    case guess_diff_type(@src)
    when "classic" then return anatomize_classic(@src)
    when "context" then return anatomize_context(@src)
    when "unified" then return anatomize_unified(@src)
    else
      raise "unsupported diff format: \n#{src.inspect}"
    end
  end

=begin obsolete
  def parsed
    case guess_diff_type(@src)
    when "classic" then @parsed = parse_classic(@src)
    when "context" then @parsed = parse_context(@src)
    when "unified" then @parsed = parse_unified(@src)
    else
      raise "unsupported diff format: \n#{src.inspect}"
    end
    @parsed
  end

  def parse_classic(src)
    eol      = "(?:\r\n|\n|\r)"
    noeol    = "(?:[^\r\n])"
    hunk_header = "(?:[0-9]+(?:,[0-9]+)?[dac][0-9]+(?:,[0-9]+)?#{eol})"
    del      = "(?:^< ?#{noeol}*?#{eol})"
    sep      = "(?:^---#{eol})"
    add      = "(?:^> ?#{noeol}*?#{eol})"
    change   = "(?:#{del}+#{sep}#{add}+)"
    misc     = "(?:.*?(?:#{eol}|\z))"
    hunk     = "(?:#{hunk_header}(?:#{change}|#{del}+|#{add}+))"
    elements = "(?:#{hunk}|#{misc})"
    parsed_elements = []
    src.scan(Regexp.new(elements, Regexp::MULTILINE)){|m|
      case
      when /\A[0-9]/.match(m) then
        parsed_elements << parse_classic_hunk(m)
      else
        parsed_elements << m
      end
    }
    parsed_elements
  end

  def parse_classic_hunk(a_hunk)
    eol      = "(?:\r\n|\n|\r)"
    noneol    = "(?:[^\r\n])"
    hunk_header = "(?:[0-9]+(?:,[0-9]+)?[dac][0-9]+(?:,[0-9]+)?#{eol})"
    del      = "(?:^< ?#{noneol}*?#{eol})"
    sep      = "(?:^---#{eol})"
    add      = "(?:^> ?#{noneol}*?#{eol})"
    pat = "(?:#{hunk_header}|#{del}+|#{sep}|#{add}+)"
    hunk_elms = {}
    a_hunk.scan(Regexp.new(pat, Regexp::MULTILINE)){|elm|
      case
      when /^[0-9]/.match(elm) then hunk_elms[:hunk_header] = elm
      when /^</.match(elm) then hunk_elms[:del] = elm
      when /^---#{eol}/.match(elm) then hunk_elms[:sep] = elm
      when /^>/.match(elm) then hunk_elms[:add] = elm
      else
        hunk_elms[:misc] = elm
      end
    }
    hunk_elms
  end

  def differentiate_classic(src)
    parsed_src = parse_classic(src)
    d = []
    parsed_src.each{|e|
      if e.kind_of?(Hash)
        d = d + differentiate_classic_hunk(e)
      else
        d << [:common_elt_elt, [e], [e]]
      end
    }
    d
  end

  def differentiate_classic_hunk(parsed_hunk)
    h = parsed_hunk
    a1 = [] << h[:hunk_header]
    a2 = [] << h[:hunk_header]
    case
    when h[:sep]
      [
       [:common_elt_elt, [h[:hunk_header]], [h[:hunk_header]]],
       [:change_elt, [h[:del]], nil],
       [:common_elt_elt, [h[:sep]], [h[:sep]]],
       [:change_elt, nil, [h[:add]]],
      ]
    when h[:del]
      a1 << h[:del]
      Difference.new(a1, a2).raw_list
    when h[:add]
      a2 << h[:add]
      Difference.new(a1, a2).raw_list
    else
      raise "bummers!"
    end
  end

  def to_manued_classic()
    enc = CharString.guess_encoding(@src)
    eol = CharString.guess_eol(@src)
    View.new(differentiate_classic(@src), enc, eol).to_manued
  end

  def parse_context(src)
    eol      = "(?:\r\n|\n|\r)"
    noeol    = "(?:[^\r\n])"
    hunk_header = "(?:[0-9]+(?:,[0-9]+)?[dac][0-9]+(?:,[0-9]+)?#{eol})"
    del      = "(?:^< ?#{noeol}*?#{eol})"
    sep      = "(?:^---#{eol})"
    add      = "(?:^> ?#{noeol}*?#{eol})"
    change   = "(?:#{del}+#{sep}#{add}+)"
    misc     = "(?:.*?(?:#{eol}|\z))"
    hunk     = "(?:#{hunk_header}(?:#{change}|#{del}+|#{add}+))"
    elements = "(?:#{hunk}|#{misc})"
    parsed_elements = []
    src.scan(Regexp.new(elements, Regexp::MULTILINE)){|m|
      case
      when /\A[0-9]/.match(m) then
        parsed_elements << parse_context_hunk(m)
      else
        parsed_elements << m
      end
    }
    parsed_elements
  end

  def parse_context_hunk(a_hunk)
    eol      = "(?:\r\n|\n|\r)"
    noneol    = "(?:[^\r\n])"
    hunk_header = "(?:[0-9]+(?:,[0-9]+)?[dac][0-9]+(?:,[0-9]+)?#{eol})"
    del      = "(?:^< ?#{noneol}*?#{eol})"
    sep      = "(?:^---#{eol})"
    add      = "(?:^> ?#{noneol}*?#{eol})"
    pat = "(?:#{hunk_header}|#{del}+|#{sep}|#{add}+)"
    hunk_elms = {}
    a_hunk.scan(Regexp.new(pat, Regexp::MULTILINE)){|elm|
      case
      when /^[0-9]/.match(elm) then hunk_elms[:hunk_header] = elm
      when /^</.match(elm) then hunk_elms[:del] = elm
      when /^---#{eol}/.match(elm) then hunk_elms[:sep] = elm
      when /^>/.match(elm) then hunk_elms[:add] = elm
      else
        hunk_elms[:misc] = elm
      end
    }
    hunk_elms
  end
=end obsolete

end

module ClassicDiff
  def eol
    "(?:\r\n|\n|\r)"
  end
  def noeol
    "(?:[^\r\n])"
  end
  def hunk_header
    "(?:[0-9]+(?:,[0-9]+)?[dac][0-9]+(?:,[0-9]+)?#{eol})"
  end
  def del
    "(?:^< ?#{noeol}*?#{eol})"
  end
  def sep
    "(?:^---#{eol})"
  end
  def add
    "(?:^> ?#{noeol}*?#{eol})"
  end
  def change
    "(?:#{del}+#{sep}#{add}+)"
  end
  def misc
    "(?:.*?(?:#{eol}|\z))"
  end
  def hunk
    "(?:#{hunk_header}(?:#{change}|#{del}+|#{add}+))"
  end
  def elements
    "(?:#{hunk}|#{misc})"
  end
end

def anatomize_classic(src)
  self.extend ClassicDiff
  diffed = []
  src_encoding = CharString.guess_encoding(src)
  src_eol = CharString.guess_eol(src)
  src.scan(Regexp.new(elements, Regexp::MULTILINE)){|m|
    case
    when /\A[0-9]/.match(m) then # hunk
      diffed = diffed + anatomize_classic_hunk(m, src_encoding, src_eol)
    else # not hunk
      diffed = diffed + Difference.new(m.to_a, m.to_a)
    end
  }
  return diffed
end

def anatomize_classic_hunk(a_hunk, src_encoding, src_eol)
  self.extend ClassicDiff
  diffed = []
  a_hunk.scan(/(#{hunk_header})(#{change}|#{del}+|#{add}+)/){|n|
    head, body = [$1, $2].collect{|e|
      e.extend(CharString)
      e.encoding, e.eol = src_encoding, src_eol
      e
    }
    diffed = diffed + Difference.new(head.split_to_word, head.split_to_word)
    case
    when /d/.match(head) # del
      diffed = diffed + Difference.new(body.split_to_word, [])
    when /a/.match(head) # add
      diffed = diffed + Difference.new([], body.split_to_word)
    when /c/.match(head) # change (need tweak)
      former, latter = body.split(/#{sep}/).collect{|e|
        e.extend(CharString)
        e.encoding, e.eol = src_encoding, src_eol
        e
      }
      diffed_former = []
      diffed_latter = []
      Difference.new(former.split_to_word, latter.split_to_word).each{|e|
        case e.first
        when :change_elt then diffed_former << [e[0], e[1], nil]
                              diffed_latter << [e[0], nil, e[2]]
        when :del_elt then    diffed_former << e
        when :add_elt then    diffed_latter << e
        when :common_elt_elt then diffed_former << e
                                  diffed_latter << e
        else raise "bummers!: #{e.first}"
        end
      }
      sepstr = /#{sep}/.match(body).to_s.extend(CharString)
      sepstr.encoding, sepstr.eol = src_encoding, src_eol
      sepelm = Difference.new(sepstr.split_to_word, sepstr.split_to_word)
      diffed = diffed + diffed_former + sepelm + diffed_latter
    else
      raise "invalid hunk header: #{head}"
    end
  }
  return diffed
end

module ContextDiff
  def eol
    "(?:\r\n|\n|\r|\z)"
  end
  def noneol
    "(?:[^\r\n])"
  end
  def hunk_header
    "(?:\\*+#{eol})"
  end
  def hunk_subheader_former
    "(?:^\\*+ [0-9]+,[0-9]+ \\*+#{eol})"
  end
  def hunk_subheader_latter
    "(?:^-+ [0-9]+,[0-9]+ -+#{eol})"
  end
  def del
    "(?:^- #{noneol}*?#{eol})"
  end
  def add
    "(?:^\\+ #{noneol}*?#{eol})"
  end
  def change
    "(?:^! #{noneol}*?#{eol})"
  end
  def misc
    "(?:^[^-+!*]+?#{eol}+?)"
  end
  def any
    "(?:#{del}+|#{add}+|#{change}+|#{misc}+)"
  end
  def file_header
    "(?:[-\\*]{3} #{noneol}+?#{eol})"
  end
  def elements
    "(?:#{file_header}|#{hunk_header}#{hunk_subheader_former}#{any}*?#{hunk_subheader_latter}#{any}+?|#{misc}|#{noneol}+#{eol})"
  end
end

def anatomize_context(src)
  self.extend ContextDiff
  diffed = []
  src_encoding = CharString.guess_encoding(src)
  src_eol = CharString.guess_eol(src)
  src.scan(/#{elements}/m){|m|
    case
    when /\A\*{10,}/.match(m) then # hunk
      diffed = diffed + anatomize_context_hunk(m.to_s, src_encoding, src_eol)
    else # not hunk
      m.extend(CharString)
      m.encoding, m.eol = src_encoding, src_eol
      diffed = diffed + Difference.new(m.to_words, m.to_words)
    end
  }
  return diffed
end

def anatomize_context_hunk(a_hunk, src_encoding, src_eol)
  self.extend ContextDiff
  diffed = []
  h, sh_f, body_f, sh_l, body_l = nil
  a_hunk.scan(/(#{hunk_header})(#{hunk_subheader_former})(.*?)(#{hunk_subheader_latter})(.*?)\z/m){
    h, sh_f, body_f, sh_l, body_l = [$1, $2, $3, $4, $5].collect{|he|
      he.extend(CharString)
      he.encoding, he.eol = src_encoding, src_eol
      he
    }
  }
  diffed_former, diffed_latter = anatomize_context_hunk_scanbodies(body_f, body_l, src_encoding, src_eol)
  diffed = diffed +
           Difference.new(h.split_to_word, h.split_to_word) +
           Difference.new(sh_f.split_to_word, sh_f.split_to_word) +
           diffed_former +
           Difference.new(sh_l.split_to_word, sh_l.split_to_word) +
           diffed_latter
  return diffed
end

def anatomize_context_hunk_scanbodies(body_f, body_l, src_encoding, src_eol)
  self.extend ContextDiff
  changes_f, changes_l = [body_f, body_l].collect{|b|
    b.scan(/#{change}+/).collect{|ch|
      if ch
        ch.extend(CharString)
        ch.encoding, ch.eol = src_encoding, src_eol
      end
      ch
    }
  }
  changes_f_bak, changes_l_bak = changes_f.dup, changes_l.dup
  diffed_f_l = [[], []]
  [body_f, body_l].each_with_index{|half, i|
    changes_f, changes_l = changes_f_bak.dup, changes_l_bak.dup
    half.scan(/(#{del}+)|(#{add}+)|(#{change}+)|(#{misc}+)/m){|elm|
      elm_d, elm_a, elm_c, elm_cmn = [elm[0], elm[1], elm[2], elm[3]]
      [elm_d, elm_a, elm_c, elm_cmn].collect{|e|
        if e
          e.extend(CharString)
          e.encoding, e.eol = src_encoding, src_eol
        end
        e
      }
      case
      when elm_d then diffed_f_l[0] = diffed_f_l.first + Difference.new(elm_d.to_words, [])
      when elm_a then diffed_f_l[1] = diffed_f_l.last + Difference.new([], elm_a.to_words)
      when elm_c then diffed_f_l[i] = diffed_f_l[i] +
        Difference.new(changes_f.shift.to_words, changes_l.shift.to_words).collect{|chg|
          chg_modified = nil
          case chg.first
          when :change_elt then     chg_modified = [:change_elt, chg[1], nil] if i == 0
                                    chg_modified = [:change_elt, nil, chg[2]] if i == 1
          when :del_elt then        chg_modified = nil if i == 0
                                    chg_modified = chg_modified if i == 1
          when :add_elt then        chg_modified = chg_modified if i == 0
                                    chg_modified = nil if i == 1
          when :common_elt_elt then chg_modified = chg
          else
            raise "bummers!"
          end
          chg_modified
        }
      when elm_cmn then diffed_f_l[i] = diffed_f_l[i] + Difference.new(elm_cmn.to_words, elm_cmn.to_words)
      else
        raise "bummers!"
      end
    } # end half.scan
  } # end each_with_index
  return diffed_f_l
end

module UnifiedDiff
  def eol
    "(?:\r\n|\n|\r|\z)"
  end
  def noneol
    "(?:[^\r\n])"
  end
  def hunk_header
    "(?:@@ #{noneol}+#{eol})"
  end
  def del
    "(?:^-#{noneol}*?#{eol})"
  end
  def add
    "(?:^\\+#{noneol}*?#{eol})"
  end
  def change
    "(?:#{del}+#{add}+)"
  end
  def common
    "(?:^ #{noneol}*?#{eol})"
  end
  def misc
    "(?:^[^-+]+?#{eol}+?)"
  end
  def any
    "(?:#{del}+|#{add}+|#{change}+|#{common}+|#{misc}+)"
  end
  def file_header
    "(?:^[^-+@ ]#{noneol}+#{eol}(?:^[-+]{3} #{noneol}+#{eol}){2})"
  end
  def elements
    "(?:#{file_header}|#{hunk_header}#{any}+?|#{misc}|#{noneol}+#{eol})"
  end
end

def anatomize_unified(src)
  self.extend UnifiedDiff
  diffed = []
  src_encoding = CharString.guess_encoding(src)
  src_eol = CharString.guess_eol(src)
  src.scan(/#{elements}/m){|m|
    case
    when /\A@@ /.match(m) then # hunk
      diffed = diffed + anatomize_unified_hunk(m.to_s, src_encoding, src_eol)
    else # not hunk
      m.extend(CharString)
      m.encoding, m.eol = src_encoding, src_eol
      diffed = diffed + Difference.new(m.to_words, m.to_words)
    end
  }
  return diffed
end

def anatomize_unified_hunk(a_hunk, src_encoding, src_eol)
  self.extend UnifiedDiff
  diffed = []
  a_hunk.scan(/(#{hunk_header})(#{any}+#{eol}?)/m){|m|
    head, body = m[0], m[1]
    [head, body].collect{|e|
      e.extend(CharString)
      e.encoding, e.eol = src_encoding, src_eol
    }
    diffed = diffed + Difference.new(head.to_words, head.to_words)
    body.scan(/(#{del}+)(#{add}+)|(#{del}+#{eol}?)|(#{add}+)|(#{common}+#{eol}?)|(.*#{eol}?)/m){|m|
      cf, cl, d, a, cmn, msc = m[0], m[1], m[2], m[3], m[4], m[5]
      [cf, cl, d, a, cmn, msc].collect{|e|
        e.extend(CharString)
        e.encoding, e.eol = src_encoding, src_eol
      }
      case
      when (cf and cl) then
        Difference.new(cf.to_words, cl.to_words).each{|e|
          case e.first
          when :change_elt     then diffed << [:change_elt, e[1], nil]
                                    diffed << [:change_elt, nil, e[2]]
          when :del_elt        then diffed << [:change_elt, e[1], nil]
          when :add_elt        then diffed << [:change_elt, nil, e[2]]
          when :common_elt_elt then diffed << e
          else raise "bummers! (#{e.inspect})"
          end
        }
      when d           then diffed = diffed + Difference.new(d.to_words, [])
      when a           then diffed = diffed + Difference.new([], a.to_words)
      when cmn         then diffed = diffed + Difference.new(cmn.to_words, cmn.to_words)
      when msc         then diffed = diffed + Difference.new(msc.to_words, msc.to_words)
      else raise "bummers! (#{m.inspect})"
      end
    }
  }
  return diffed
end

if $0 == __FILE__

  src = ARGF.read
  enc, eol = CharString.guess_encoding(src), CharString.guess_eol(src)

  anatomy = DiffFile.new(src).anatomize
  view = View.new(anatomy, enc, eol)

  print view.to_tty
  p view

end
