#!/usr/bin/ruby

class View

  def initialize(difference, encoding, eol)
    @difference = difference
    @encoding = encoding
    @eol = eol
#     if CharString::EOLChars[@eol]
#       @eol_char = CharString::EOLChars[@eol].eol_char
#     else
#       @eol_char = nil
#     end
  end

  def apply_style(tags)
    result = []
    @difference.each{|block|
      operation = block.first
      if block_given?
        source = yield block[1].to_s
        target = yield block[2].to_s
      else
        source = block[1].to_s
        target = block[2].to_s
      end
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
    tags.update(overriding_tags) if overriding_tags
    apply_style(tags)
  end

  HTMLEscapeDic = {'<'=>'&lt;', '>'=>'&gt;', '&'=>'&amp;', ' '=>'&nbsp;',
                   "\r\n" => "<br>\r\n", "\r" => "<br>\r", "\n" => "<br>\n"}
  HTMLEscapePat = /(\r\n|#{HTMLEscapeDic.keys.collect{|k|Regexp.quote(k)}.join('|')})/m
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
    tags.update(overriding_tags) if overriding_tags
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
      apply_style(tags){|str_to_escape|
        str_to_escape.gsub(HTMLEscapePat){|matched| HTMLEscapeDic[matched]}
      }
    end
  end

  XHTMLEscapeDic = {'<'=>'&lt;', '>'=>'&gt;', '&'=>'&amp;', ' '=>'&nbsp;',
                   "\r\n" => "<br />\r\n", "\r" => "<br />\r", "\n" => "<br />\n"}
  XHTMLEscapePat = /(\r\n|#{XHTMLEscapeDic.keys.collect{|k|Regexp.quote(k)}.join('|')})/m
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
    tags.update(overriding_tags) if overriding_tags
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
      apply_style(tags){|str_to_escape|
        str_to_escape.gsub(XHTMLEscapePat){|matched| XHTMLEscapeDic[matched]}
      }
    end
  end

  ManuedInsideEscapeDic = {'~'=>'~~', '/'=>'~/', '['=>'~[', ']'=>'~]', ';'=>'~;'}
  ManuedInsideEscapePat = /(#{ManuedInsideEscapeDic.keys.collect{|k|Regexp.quote(k)}.join('|')})/m
  ManuedOutsideEscapeDic = {'~'=>'~~', '['=>'~['}
  ManuedOutsideEscapePat = /(#{ManuedOutsideEscapeDic.keys.collect{|k|Regexp.quote(k)}.join('|')})/m
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
    tags.update(overriding_tags) if overriding_tags
    result = []
    if headfoot == true
      result =
      ["defparentheses [ ]\n",
       "defdelete      /\n",
       "defswap        |\n",
       "defcomment     ;\n",
       "defescape      ~\n",
       "deforder       newer-last\n",
       "defversion     0.9.5\n"] + result
    end
    @difference.each{|block|
      operation = block.first
      source = block[1].to_s
      target = block[2].to_s
      case operation
      when :common_elt_elt
        result << (tags[:start_common] + source.gsub(ManuedOutsideEscapePat){|matched| ManuedOutsideEscapeDic[matched]} + tags[:end_common])
      when :change_elt
        result << (tags[:start_before_change] + 
                   source.gsub(ManuedInsideEscapePat){|matched| ManuedInsideEscapeDic[matched]} + 
                   tags[:end_before_change] + 
                   tags[:start_after_change] + 
                   target.gsub(ManuedInsideEscapePat){|matched| ManuedInsideEscapeDic[matched]} + 
                   tags[:end_after_change])
      when :del_elt
        result << (tags[:start_del] + source.gsub(ManuedInsideEscapePat){|matched| ManuedInsideEscapeDic[matched]} + tags[:end_del])
      when :add_elt
        result << (tags[:start_add] + target.gsub(ManuedInsideEscapePat){|matched| ManuedInsideEscapeDic[matched]} + tags[:end_add])
      else
        raise "invalid attribute: #{block.first}\n"
      end
    }
    result
  end

  def to_wdiff(overriding_tags = nil, headfoot = false)
    tags = {:start_common        => '',
            :end_common          => '',
            :start_del           => '[-',
            :end_del             => '-]',
            :start_add           => '{+',
            :end_add             => '+}',
            :start_before_change => '[-',
            :end_before_change   => '-]',
            :start_after_change  => '{+',
            :end_after_change    => '+}'}
    tags.update(overriding_tags) if overriding_tags
    apply_style(tags)
  end

  def to_user(overriding_tags = nil, headfoot = false)
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
    tags.update(overriding_tags) if overriding_tags
    apply_style(tags)
  end

  def to_debug()
  end

end
