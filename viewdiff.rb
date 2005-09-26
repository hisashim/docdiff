#!/usr/bin/ruby

require 'docdiff/difference'
require 'docdiff/document'
require 'docdiff/view'
require 'docdiff/charstring'

require "tempfile"

$KCODE="e"

=begin

classic:

  Diff
    FilePair
      commandline               diff --opt dir1/file dir2/file
      file1                     nil
      file2                     nil
      Hunk
        header                  1,2c3,4
        file1_header            nil
        Line
          mark content          < foo
        sep                     ---
        file2_header            nil
        mark content            > bar
    Other                       Only in somedir: baz

context:

  Diff
    FilePair
      commandline               diff --opt dir1/file dir2/file
      file1                     *** dir1/file timestamp
      file2                     --- dir2/file timestamp
      Hunk
        header                  ***************
        file1_header            *** 1,17 ****
        Line
          mark content          - foo
        sep                     nil
        file2_header            --- 1,18 ----
        mark content            + bar
    Other                       \ No newline at end of file

unified:

  Diff
    FilePair
      commandline               diff --opt dir1/file dir2/file
      file1                     --- dir1/file timestamp
      file2                     +++ dir2/file timestamp
      Hunk
        header                  @@ -1,17 +1,18 @@
        file1_header            nil
        Line
          mark content          -foo
        sep                     nil
        file2_header            nil
        mark content            +bar
    Other                       \ No newline at end of file

How to use:

d = DiffFile.new(ARGF.read, encoding, eol)
  (parse)
print d.to_tty
  (compare hunks)
  (format)

=end

module Enumerable
  def collect_with_index
    ary = []
    self.each_index {|i|
      ary << yield(self[i], i)
    }
    return ary
  end
end

class String
  attr_accessor(:op, :counterpart, :mark, :content)
end

class DiffFile


  def DiffFile.guess_diff_type(text)
    text.extend(CharString)
    case
    when (/^[<>] /m).match(text) then return "classic"
    when (/^[-+!] /m).match(text) then return "context"
    when (/^[-+]/m).match(text) then return "unified"
    else raise "unknown diff format."
    end
  end

  def initialize(diff)
    @src = diff
    case DiffFile.guess_diff_type(diff)
    when "classic" then @parsed_diff = parse_classic_diff(diff)
    when "context" then @parsed_diff = parse_context_diff(diff)
    when "unified" then @parsed_diff = parse_unified_diff(diff)
    else
      raise "unsupported diff format: \n#{diff}"
    end
#     @diff_header = parsed_diff.diff_header
#     @file_header = parsed_diff.file_header
#     @hunks = parsed_diff.hunks
  end
  attr_reader(:src, :parsed_diff)

  def parse_classic_diff_old(diff)  # obsolete
    range = '[0-9]+(?:,[0-9]+)?'
    op = '[dac]'
    eol = '(?:\r\n|\n|\r)'

    cmdline = '^[^-0-9<>].*?' + eol
    hunk_header = range + op + range + eol
    del = '(?:< ?.*?' + eol + ')+'
    sep = '^---' + eol
    add = '(?:> ?.*?' + eol + ')+'

    pat = [cmdline, hunk_header, del, sep, add].join('|')
    elements = diff.scan(Regexp.new(pat, Regexp::MULTILINE))
    elements.collect_with_index{|elm, i|
      case
      when Regexp.compile("^" + del).match(elm) then
        elm.op = "del"
        elm.mark, elm.content = elm[0..1], elm[2..-1]
        if ((i + 2) < elements.size) && (Regexp.compile(sep).match(elements[i + 1]))
          elm.counterpart = elements[i + 2]
        end
      when Regexp.compile("^" + add).match(elm) then
        elm.op = "add"
        elm.mark, elm.content = elm[0..1], elm[2..-1]
        if (0 <= (i - 2)) && (Regexp.compile(sep).match elements[i - 1])
          elm.counterpart = elements[i - 2]
        end
      end
      elm
    }
  end
  def parse_classic_diff_compat_with_old(diff)  # obsolete
    elements = tokenize_classic_diff(diff)
    parsed = []
    elements.collect_with_index{|elm, i|
      case
      when Regexp.new("^"+'(?:< ?.*?(?:\r\n|\n|\r))').match(elm) then elm.op = "del"
      when Regexp.new("^"+'(?:> ?.*?(?:\r\n|\n|\r))').match(elm) then elm.op = "add"
      end
      if parsed.size > 0 && elm.op != nil && elm.op == parsed.last.op
        parsed.last.replace(parsed.last + elm)
      else
        parsed << elm
      end
    }
    parsed
  end
  def parse_classic_diff(diff)
    elements = tokenize_classic_diff(diff)
    parsed = []
    elements.collect_with_index{|elm, i|
      case
      when Regexp.new("^"+'(?:< ?.*?(?:\r\n|\n|\r))').match(elm) then elm.op = "del"
      when Regexp.new("^"+'(?:> ?.*?(?:\r\n|\n|\r))').match(elm) then elm.op = "add"
      end
      parsed << elm
    }
    parsed
    # hack more
  end
  def tokenize_classic_diff(diff)
    range = '[0-9]+(?:,[0-9]+)?'
    op = '[dac]'
    eol = '(?:\r\n|\n|\r)'

    cmdline = '^[^-0-9<>].*?' + eol
    hunk_header = range + op + range + eol
    del = '(?:< ?.*?' + eol + ')'
    sep = '^---' + eol
    add = '(?:> ?.*?' + eol + ')'

    pat = [cmdline, hunk_header, del, sep, add].join('|')
    return diff.scan(Regexp.new(pat, Regexp::MULTILINE))
  end

  def parse_context_diff(diff)
    eol = '(?:\r\n|\n|\r)'
    cmdline = '^[^-\+\*\! ].*?' + eol
    hunk_sep = '^\*+' + eol
    file_header1 = '^\*{3} .*?' + eol
    file_header2 = '^\-{3} .*?' + eol
    hunk_heading1 = '^\*{3} [0-9]+,[0-9]+ \*{4}' + eol
    hunk_heading2 = '^\-{3} [0-9]+,[0-9]+ \-{4}' + eol

    del = '(?:\-[^-].*?' + eol + ')+'
    add = '(?:\+[^+].*?' + eol + ')+'
    change = '(?:\! ?.*?' + eol + ')+'
    any = '(?:.*?)' + eol

    pat = [cmdline, hunk_sep, file_header1, file_header2,
           hunk_heading1, hunk_heading2, del, add, change, any].join('|')
    elements = diff.scan(Regexp.new(pat, Regexp::MULTILINE))
    changes_in_former_half_of_hunk = []
    changes_in_latter_half_of_hunk = []
    in_latter_half = false
    elements.collect_with_index{|elm, i|
      case
      when Regexp.compile("^" + del).match(elm) then
        elm.op = "del"
        elm.mark, elm.content = elm[0..1], elm[2..-1]
      when Regexp.compile("^" + add).match(elm) then
        elm.op = "add"
        elm.mark, elm.content = elm[0..1], elm[2..-1]
      when Regexp.compile("^" + change).match(elm) then
        elm.op = "change"
        elm.mark, elm.content = elm[0..1], elm[2..-1]
        if in_latter_half
          elm.counterpart = changes_in_former_half_of_hunk.shift
          elm.counterpart.counterpart = elm
          changes_in_latter_half_of_hunk << elm
        else
          changes_in_former_half_of_hunk << elm
        end
      when Regexp.compile("^" + hunk_heading1).match(elm) then
        in_latter_half = false
        changes_in_former_half_of_hunk = []
      when Regexp.compile("^" + hunk_heading2).match(elm) then
        in_latter_half = true
        changes_in_latter_half_of_hunk = []
      end
      elm
    }
  end

=begin
  def parse_unified_diff(diff)
  end
=end
end

########

re_src_eol       = '(?:\r\n|\n|\r)'
re_src_del_fname = '---.*?' + re_src_eol
re_src_ins_fname = '\+\+\+.*?' + re_src_eol
re_src_del       = '^-.*?' + re_src_eol
re_src_ins       = '^\+.*?' + re_src_eol
re_src_anything  = '.+?' + re_src_eol

re = Regexp.new('(' + re_src_del_fname + ')|(' + re_src_ins_fname + 
                ')|(' + re_src_del + ')|(' + re_src_ins + 
                ')|(' + re_src_anything + ')' , Regexp::MULTILINE)
deleted  = []
inserted = []

if $0 == __FILE__

ARGF.read.scan(re){|m|
  print $1 if $1
  print $2 if $2
  if $3
    deleted << $3
  end
  if $4
    inserted << $4
  end
  if ($3.nil? && $4.nil? && (inserted || deleted))
    d1 = Tempfile.new(File.basename(__FILE__))
    d1.print(deleted || "")
    deleted.clear
    d1.close
    d2 = Tempfile.new(File.basename(__FILE__))
    d2.print(inserted || "")
    inserted.clear
    d2.close
    cl = "docdiff --eucjp --lf --tty #{d1.path} #{d2.path}"
    print IO.popen(cl,"r").read
    d1.close(true)
    d2.close(true)
  end
  print $5 if $5
}

end
