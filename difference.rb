# Difference class for DocDiff
# 2003-03-24 .. 
# Hisashi MORITA

require 'diff'

class Difference < Array

  @resolution = nil # char, word, phrase, sentence, line, paragraph..
  @codeset = ''
  @eol_char = "\n"
  @source = 'source'
  @target = 'target'
  attr_accessor :resolution, :codeset, :eol_char, :source, :target

  def initialize(array1 = nil, array2 = nil)
    if (array1 == nil) && (array2 == nil)
      return []
    end
    diff = Diff.new(array1, array2)
    @raw_list = []
    diff.ses.each{|block|  # Diff::EditScript does not have each_with_index()
      @raw_list << block
    }
    combine_del_add_to_change!()
  end

  def combine_del_add_to_change!()

    @raw_list.each_with_index{|block, i|
      case block.first
      when :common_elt_elt
        if i == 0                       # first block
          self << block
        else                            # in-between or the last block
          if @raw_list[i - 1].first == :del_elt  # previous block was del
            self << @raw_list[i - 1]
            self << block
          else                                   # previous block was add
            self << block
          end
        end
      when :del_elt
        if i == (@raw_list.size - 1)    # last block
          self << block
        else                            # first block or in-between
          # do nothing, let the next block to decide what to do
        end
      when :add_elt
        if i == 0                       # first block
          self << block
        else                            # in-between or the last block
          if @raw_list[i - 1].first == :del_elt  # previous block was del
            deleted = @raw_list[i - 1][1]
            added   = @raw_list[i][2]
            self << [:change_elt, deleted, added]
          else                                   # previous block was common
            self << block
          end
        end
      else
        raise "the first element of the block #{i} is invalid: (#{block.first})\n"
      end
    }
  end
  attr_accessor :raw_list

  def apply_style(tags)
    result = []
    self.each{|block|
      operation = block.first
      source = block[1].to_s
      target = block[2].to_s
      case operation
      when :common_elt_elt
        result << (tags[:start_common] + source + tags[:end_common])
      when :change_elt
        result << (tags[:start_before_change] + 
                   source + 
                   tags[:end_before_change] + 
                   tags[:start_after_change] + 
                   target + 
                   tags[:end_after_change])
      when :del_elt
        result << (tags[:start_del] + source + tags[:end_del])
      when :add_elt
        result << (tags[:start_add] + target + tags[:end_add])
      else
        raise "invalid attribute: #{block.first}\n"
      end
    }
    result
  end

  def to_terminal(overriding_tags = nil)  # color escape sequence
    tags = {
      :start_common        => '',
      :end_common          => '',
      :start_del           => "\033[#{4}m\033[#{41}m",  # underscore + bg_red
      :end_del             => "\033[0m",
      :start_add           => "\033[#{1}m\033[#{44}m",  # bold + bg_blue
      :end_add             => "\033[0m",
      :start_before_change => "\033[#{4}m\033[#{43}m",  # underscore + bg_yellow
      :end_before_change   => "\033[0m",
      :start_after_change  => "\033[#{1}m\033[#{42}m",  # bold + bg_green
      :end_after_change    => "\033[0m"
    }
    if overriding_tags
      tags = tags.merge(overriding_tags)
    end
    apply_style(tags)
  end

  def to_html(overriding_tags = nil, headfoot = false)
    tags = {:start_common        => '<span class="common">',
            :end_common          => '</span>',
            :start_del           => '<span class="del"><del>',
            :end_del             => '</del></span>',
            :start_add           => '<span class="add"><ins>',
            :end_add             => '</ins></span>',
            :start_before_change => '<span class="before_change"><del>',
            :end_before_change   => '</del></span>',
            :start_after_change  => '<span class="after_change"><ins>',
            :end_after_change    => '</ins></span>'}
    if overriding_tags
      tags = tags.merge(overriding_tags)
    end
    if headfoot == true
      ['<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"',
       '"http://www.w3.org/TR/html4/loose.dtd">' + @eol_char,
       '<html><head>',
       '<meta http-equiv="Content-Type" content="text/html; charset=' +
        @codeset + '">' + @eol_char,
       '<title>' + @source + ', ' + @target + '</title>' + @eol_char,
       '<style type="text/css"></style>' + @eol_char,
       '</head><body>' + @eol_char] +
      apply_style(tags) +
      [@eol_char + '</body></html>' + @eol_char]
    else
      apply_style(tags)
    end
  end

  def to_xhtml(overriding_tags = nil, headfoot = false)
    tags = {:start_common        => '<span class="common">',
            :end_common          => '</span>',
            :start_del           => '<span class="del"><del>',
            :end_del             => '</del></span>',
            :start_add           => '<span class="add"><ins>',
            :end_add             => '</ins></span>',
            :start_before_change => '<span class="before_change"><del>',
            :end_before_change   => '</del></span>',
            :start_after_change  => '<span class="after_change"><ins>',
            :end_after_change    => '</ins></span>'}
    if overriding_tags
      tags = tags.merge(overriding_tags)
    end
    if headfoot == true
      ['<?xml version="1.0" encoding="' + @codeset.downcase+ '"?>' + @eol_char,
       '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"' + @eol_char,
       '"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">' + @eol_char,
       '<html><head>' + @eol_char,
       '<meta http-equiv="Content-Type" content="text/html; charset=' +
        @codeset.downcase + '" />',
       '<title>' + @source + ', ' + @target + '</title>' + @eol_char,
       '<style type="text/css">',
       '<!-- -->' + @eol_char,
       '</style>' + @eol_char,
       '</head><body>' + @eol_char] +
      apply_style(tags) +
      [@eol_char + '</body></html>' + @eol_char]
    else
      apply_style(tags)
    end
  end

  def to_manued(overriding_tags = nil, headfoot = false)  # [ / ; ]
    tags = {:start_common        => '',
            :end_common          => '',
            :start_del           => '[',
            :end_del             => '/]',
            :start_add           => '[/',
            :end_add             => ']',
            :start_before_change => '[',
            :end_before_change   => '/',
            :start_after_change  => '',
            :end_after_change    => ']'}
    if overriding_tags
      tags = tags.merge(overriding_tags)
    end
    if headfoot == true
      ["defparentheses [ ]\n",
       "defdelete      /\n", 
       "defswap        |\n",
       "defcomment     ;\n",
       "defescape      ~\n",
       "deforder       newer-last\n",
       "defversion     0.9.5\n"] +
      apply_style(tags)
    else
      apply_style(tags)
    end
  end

  def to_docdiff(overriding_tags = nil, headfoot = false)
    tags = {:start_common        => '',
            :end_common          => '',
            :start_del           => '',
            :end_del             => '',
            :start_add           => '',
            :end_add             => '',
            :start_before_change => '',
            :end_before_change   => '',
            :start_after_change  => '',
            :end_after_change    => ''}
    if overriding_tags
      tags = tags.merge(overriding_tags)
    end
    apply_style(tags)
  end

  def to_debug()
  end

end  # class Difference
