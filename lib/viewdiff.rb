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

class DocDiff
def scan_text_for_diffs(src)
  eol = "(?:\r\n|\n|\r)"
  pats = {
    :classic => "(?:[0-9]+(?:,[0-9]+)?[dac][0-9]+(?:,[0-9]+)?#{eol}.+?(?=^[^-<>0-9 ]))",
    :context => "(?:^\\*{3} .+?#{eol}--- .+?#{eol}.+?(?=^[^-+! *]|\\z))",
    :unified => "(?:^--- .+?#{eol}^\\+{3} .+?#{eol}.+?(?=^[^-+ @]|\\z))"
  }
  src.scan(/(?:#{pats.values.join("|")})|(?:.*?#{eol}+)/m)
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
    else                               return "unknown"
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
      diffed.concat(anatomize_classic_hunk(m, src_encoding, src_eol))
    else # not hunk
      diffed.concat(Difference.new(m.split(/^/), m.split(/^/)))
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
    diffed.concat(Difference.new(head.to_words, head.to_words))
    case
    when /d/.match(head) # del
      diffed.concat(Difference.new(body.to_words, []))
    when /a/.match(head) # add
      diffed.concat(Difference.new([], body.to_words))
    when /c/.match(head) # change (need tweak)
      former, latter = body.split(/#{sep}/).collect{|e|
        e.extend(CharString)
        e.encoding, e.eol = src_encoding, src_eol
        e
      }
      d = Difference.new(former.to_words, latter.to_words)
      diffed_former = d.former_only
      diffed_latter = d.latter_only
      sepstr = /#{sep}/.match(body).to_s.extend(CharString)
      sepstr.encoding, sepstr.eol = src_encoding, src_eol
      sepelm = Difference.new(sepstr.to_words, sepstr.to_words)
      diffed.concat(diffed_former + sepelm + diffed_latter)
    else
      raise "invalid hunk header: #{head}"
    end
  }
  return diffed
end

module ContextDiff
  def eol
    "(?:\r\n|\n|\r|\\z)"
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
    "(?:#{file_header}|#{hunk_header}#{hunk_subheader_former}#{any}*?#{hunk_subheader_latter}#{any}+|#{misc}|#{noneol}+#{eol})"
  end
end

def anatomize_context(src)
  self.extend ContextDiff
  diffed = []
  src_encoding = CharString.guess_encoding(src)
  src_eol = CharString.guess_eol(src)
  src.scan(/#{elements}/m){|m|
    case
    when /\A\*{10,}#{eol}^\*{3} /.match(m) then # hunk
      diffed.concat(anatomize_context_hunk(m, src_encoding, src_eol))
    else # not hunk
      m.extend(CharString)
      m.encoding, m.eol = src_encoding, src_eol
      diffed.concat(Difference.new(m.to_words, m.to_words))
    end
  }
  return diffed
end

def anatomize_context_hunk(a_hunk, src_encoding, src_eol)
  self.extend ContextDiff
  diffed = []
  h, sh_f, body_f, sh_l, body_l = nil
  a_hunk.scan(/(#{hunk_header})(#{hunk_subheader_former})(.*?)(#{hunk_subheader_latter})(.*?)\z/m){|m|
    h, sh_f, body_f, sh_l, body_l = m[0..4].collect{|he|
      if he
        he.extend(CharString)
        he.encoding, he.eol = src_encoding, src_eol
      end
      he
    }
  }
  diffed_former, diffed_latter = anatomize_context_hunk_scanbodies(body_f, body_l, src_encoding, src_eol)
  diffed.concat(Difference.new(h.to_words, h.to_words) +
                Difference.new(sh_f.to_words, sh_f.to_words) +
                diffed_former +
                Difference.new(sh_l.to_words, sh_l.to_words) +
                diffed_latter)
  return diffed
end

def anatomize_context_hunk_scanbodies(body_f, body_l, src_encoding, src_eol)
  body_f = '' if body_f.nil?
  body_l = '' if body_l.nil?
  self.extend ContextDiff
  changes_org = [[], []]
  changes_org[0], changes_org[1] = [body_f, body_l].collect{|b|
    b.scan(/#{change}+/).collect{|ch|
      if ch
        ch.extend(CharString)
        ch.encoding, ch.eol = src_encoding, src_eol
      end
      ch
    }
  }
  changes = changes_org.dup
  diffed = [[], []]
  [body_f, body_l].each_with_index{|half, i|
    changes[0], changes[1] = changes_org[0].dup, changes_org[1].dup
    half.scan(/(#{del}+)|(#{add}+)|(#{change}+)|(#{misc}+)/m){|elm|
      elm_d, elm_a, elm_c, elm_cmn = elm[0..3]
      [elm_d, elm_a, elm_c, elm_cmn].collect{|e|
        if e
          e.extend(CharString)
          e.encoding, e.eol = src_encoding, src_eol
        end
        e
      }
      case
      when elm_d then d = Difference.new(elm_d.to_words, [])
      when elm_a then d = Difference.new([], elm_a.to_words)
      when elm_c then d = Difference.new(changes[0].shift.to_words, changes[1].shift.to_words)
        case i
        when 0 then d = d.former_only
        when 1 then d = d.latter_only
        else raise
        end
      when elm_cmn then d = Difference.new(elm_cmn.to_words, elm_cmn.to_words)
      else
        raise "bummers!"
      end
      diffed[i].concat(d)
    } # end half.scan
  } # end each_with_index
  return diffed
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
      diffed.concat(anatomize_unified_hunk(m.to_s, src_encoding, src_eol))
    else # not hunk
      m.extend(CharString)
      m.encoding, m.eol = src_encoding, src_eol
      diffed.concat(Difference.new(m.to_words, m.to_words))
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
    diffed.concat(Difference.new(head.to_words, head.to_words))
    body.scan(/(#{del}+)(#{add}+)|(#{del}+#{eol}?)|(#{add}+)|(#{common}+#{eol}?)|(.*#{eol}?)/m){|m|
      cf, cl, d, a, cmn, msc = m[0..5]
      [cf, cl, d, a, cmn, msc].collect{|e|
        next if e.nil?
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
      when d           then diffed.concat(Difference.new(d.to_words, []))
      when a           then diffed.concat(Difference.new([], a.to_words))
      when cmn         then diffed.concat(Difference.new(cmn.to_words, cmn.to_words))
      when msc         then diffed.concat(Difference.new(msc.to_words, msc.to_words))
      else raise "bummers! (#{m.inspect})"
      end
    }
  }
  return diffed
end
end  # class DocDiff

if $0 == __FILE__

  src = ARGF.read
  enc, eol = DocDiff::CharString.guess_encoding(src),
             DocDiff::CharString.guess_eol(src)
  DocDiff.new.scan_text_for_diffs(src).each{|fragment|
    if DocDiff::DiffFile.new('').guess_diff_type(fragment) == "unknown"
      print fragment
    else
      diff = DocDiff::DiffFile.new(fragment).anatomize
      print DocDiff::View.new(diff, enc, eol).to_tty
    end
  }

end
