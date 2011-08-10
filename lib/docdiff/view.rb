#!/usr/bin/ruby

class String
  def scan_lines(eol)
    case eol
    when nil then    scan(/\A.*\Z/m)
    when "CR" then   scan(/.*?\r|[^\r]+\Z/m)
    when "LF" then   scan(/.*?\n|[^\n]+\Z/m)
    when "CRLF" then scan(/.*?\r\n|.+\Z/m)
    else raise "#{eol} is not supported.\n"
    end
  end
  def scan_eols(eol)
    case eol
    when nil then    []
    when "CR" then   scan(/\r/m)
    when "LF" then   scan(/\n/m)
    when "CRLF" then scan(/\r\n/m)
    else raise "#{eol} is not supported.\n"
    end
  end
end

class View

#  EOL_CHARS_PAT = Regexp.new(/\r\n|\r(?!\n)|(?:\A|[^\r])\n/m)

  def initialize(difference, encoding, eol)
    @difference = difference
    @encoding = encoding
    @eol = eol
    @eol_char = {'CR'=>"\r", 'LF'=>"\n", 'CRLF'=>"\r\n"}[@eol]
#     if CharString::EOLChars[@eol]
#       @eol_char = CharString::EOLChars[@eol].eol_char
#     else
#       @eol_char = nil
#     end
  end

  def difference_whole()
    @difference
  end

  def difference_digest()
    #
  end

  def escape_inside(str, tags)
    str.gsub(tags[:inside_escape_pat]){|m| tags[:inside_escape_dic][m]}
  end
  def escape_outside(str, tags)
    str.gsub(tags[:outside_escape_pat]){|m| tags[:outside_escape_dic][m]}
  end

  def apply_style(tags, headfoot = true)
    result = []
    @difference.each{|block|
      operation = block.first
      if block_given?
        src = yield((block[1] || []).join)
        tgt = yield((block[1] || []).join)
      else
        src = (block[1] || []).join
        tgt = (block[2] || []).join
      end
      case operation
      when :common_elt_elt
        result << (tags[:start_common] + escape_outside(src, tags) + tags[:end_common])
      when :change_elt
        result << (tags[:start_before_change] + escape_inside(src, tags) + tags[:end_before_change] +
                   tags[:start_after_change]  + escape_inside(tgt, tags) + tags[:end_after_change])
      when :del_elt
        result << (tags[:start_del] + escape_inside(src, tags) + tags[:end_del])
      when :add_elt
        result << (tags[:start_add] + escape_inside(tgt, tags) + tags[:end_add])
      else
        raise "invalid attribute: #{block.first}\n"
      end
    }
    if headfoot == true
      result = tags[:header] + result + tags[:footer]
    end
    result.delete_if{|elem|elem==''}
  end

  def encname_for_regexp(encname)
    def ruby_m17n?
      "".respond_to?(:force_encoding)
    end
    if ruby_m17n?
      # in 1.9.x, encoding names are deprecated except for N (ASCII-8BIT (binary))
      nil
    else
      # in 1.8.x, U|E|S|N are accepted
      encname.sub(/US-ASCII/i, 'none')
    end
  end

  CONTEXT_PRE_LENGTH  = 32
  CONTEXT_POST_LENGTH = 32
  def apply_style_digest(tags, headfoot = true)
    cxt_pre_pat  = Regexp.new('.{0,'+"#{CONTEXT_PRE_LENGTH}"+'}\Z',
                              Regexp::MULTILINE, encname_for_regexp(@encoding))
    cxt_post_pat = Regexp.new('\A.{0,'+"#{CONTEXT_POST_LENGTH}"+'}',
                              Regexp::MULTILINE, encname_for_regexp(@encoding))
    display = (tags and tags[:display]) || 'inline'
    result = []
    d1l = doc1_line_number = 1
    d2l = doc2_line_number = 1
    @difference.each_with_index{|entry, i|
      if block_given?
        src = yield((entry[1] || []).join)
        tgt = yield((entry[1] || []).join)
      else
        src = (entry[1] || []).join
        tgt = (entry[2] || []).join
      end
      cxt_pre = if i == 0
                   ""  # no pre context for the first entry
                else
                  (@difference[i-1][1] || []).join.scan(cxt_pre_pat).join
                end
      cxt_post = if (i + 1) == @difference.size
                   ""  # no post context for the last entry
                 else
                   (@difference[i+1][1] || []).join.scan(cxt_post_pat).join
                 end
      # elements for an entry
      e_head     = Proc.new {|pos_str|
                             tags[:start_entry] + tags[:start_position] + pos_str + tags[:end_position]}
      e_cxt_pre  = tags[:start_prefix] + escape_outside(cxt_pre, tags) + tags[:end_prefix]
      e_src      = escape_inside(src, tags)
      e_chg      = tags[:start_before_change] + escape_inside(src, tags)  + tags[:end_before_change] +
                   tags[:start_after_change]  + escape_inside(tgt, tags)  + tags[:end_after_change]
      e_chgdel   = tags[:start_before_change] + escape_inside(src, tags)  + tags[:end_before_change]
      e_chgadd   = tags[:start_after_change]  + escape_inside(tgt, tags)  + tags[:end_after_change]
      e_del      = tags[:start_del]           + escape_outside(src, tags) + tags[:end_del]
      e_add      = tags[:start_add]           + escape_outside(tgt, tags) + tags[:end_add]
      e_cxt_post = tags[:start_postfix]       + escape_outside(cxt_post, tags) + tags[:end_postfix]
      e_foot     = tags[:end_entry] + (@eol_char||"")

      span1 = source_lines_involved = src.scan_lines(@eol).size
      span2 = target_lines_involved = tgt.scan_lines(@eol).size
      pos_str = ""
      case operation = entry.first
      when :common_elt_elt
        # skipping common part
      when :change_elt
        pos_str = "#{d1l}" + "#{if span1 > 1 then '-'+(d1l + span1 - 1).to_s; end}" +
                  ",#{d2l}" + "#{if span2 > 1 then '-'+(d2l + span2 - 1).to_s; end}"
        case display
        when 'inline'
          result << (e_head.call(pos_str) + e_cxt_pre + e_chg + e_cxt_post + e_foot)
        when 'multi'
          result << (e_head.call(pos_str) + e_cxt_pre + e_chgdel + e_cxt_post +
                                            e_cxt_pre + e_chgadd + e_cxt_post + e_foot)
        else raise "Unsupported display type: #{display}"
        end
      when :del_elt
        pos_str = "#{d1l}" + "#{if span1 > 1 then '-'+(d1l + span1 - 1).to_s; end}" +
                  ",(#{d2l})"
        case display
        when 'inline'
          result << (e_head.call(pos_str) + e_cxt_pre + e_del + e_cxt_post + e_foot)
        when 'multi'
          result << (e_head.call(pos_str) + e_cxt_pre + e_src + e_cxt_post +
                                            e_cxt_pre + e_del + e_cxt_post + e_foot)
        else raise "Unsupported display type: #{display}"
        end
      when :add_elt
        pos_str = "(#{d1l})" +
                  ",#{d2l}" + "#{if span2 > 1 then '-'+(d2l + span2 - 1).to_s; end}"
        case display
        when 'inline'
          result << (e_head.call(pos_str) + e_cxt_pre + e_add + e_cxt_post + e_foot)
        when 'multi'
          result << (e_head.call(pos_str) + e_cxt_pre + e_src + e_cxt_post +
                                            e_cxt_pre + e_add + e_cxt_post + e_foot)
        else raise "Unsupported display type: #{display}"
        end
      else
        raise "invalid attribute: #{block.first}\n"
      end
      d1l += src.scan_eols(@eol).size
      d2l += tgt.scan_eols(@eol).size
    }
    result.unshift(tags[:start_digest_body])
    result.push(tags[:end_digest_body])
    result = tags[:header] + result + tags[:footer] if headfoot == true
    result.delete_if{|elem| elem == ''}
  end

  def source_lines()
    if @source_lines == nil
      @source_lines = @difference.collect{|entry| entry[1]}.join.scan_lines(@eol)
    end
    @source_lines
  end
  def target_lines()
    if @target_lines == nil
      @target_lines = @difference.collect{|entry| entry[2]}.join.scan_lines(@eol)
    end
    @target_lines
  end

  # tty (terminal)
  def tty_header()
    []
  end
  def tty_footer()
    []
  end
  TTYEscapeDic = {'ThisRandomString' => 'ThisRandomString'}
  TTYEscapePat = /(\r\n|#{TTYEscapeDic.keys.collect{|k|Regexp.quote(k)}.join('|')})/m
  def tty_tags()
    {:outside_escape_dic  => TTYEscapeDic,
     :outside_escape_pat  => TTYEscapePat,
     :inside_escape_dic   => TTYEscapeDic,
     :inside_escape_pat   => TTYEscapePat,
     :start_digest_body   => "----#{@eol_char||''}",
     :end_digest_body     => '',
     :start_entry         => '',
     :end_entry           => "----",
     :start_position      => '',
     :end_position        => "#{@eol_char||''}",
     :start_prefix        => '',
     :end_prefix          => '',
     :start_postfix       => '',
     :end_postfix         => "#{@eol_char||''}",
     :header              => tty_header(),
     :footer              => tty_footer(),
     :start_common        => '',
     :end_common          => '',
     :start_del           => "\033[7;4;31m",  # Inverted, Underlined, Red
     :end_del             => "\033[0m",
     :start_add           => "\033[7;1;34m",  # Inverted, Bold, Blue
     :end_add             => "\033[0m",
     :start_before_change => "\033[7;4;33m",  # Inverted, Underlined, Yellow
     :end_before_change   => "\033[0m",
     :start_after_change  => "\033[7;1;32m",  # Inverted, Bold, Green
     :end_after_change    => "\033[0m"}
  end
  def to_tty(overriding_opts = nil, headfoot = true)  # color escape sequence
    tags = tty_tags()
    tags.update(overriding_opts) if overriding_opts
    apply_style(tags, headfoot)
  end
  def to_tty_digest(overriding_opts = nil, headfoot = true)
    tags = tty_tags
    tags.update(overriding_opts) if overriding_opts
    apply_style_digest(tags, headfoot)
  end

  # HTML (XHTML)
  def html_header()
    ["<?xml version=\"1.0\" encoding=\"#{@encoding||''}\"?>#{@eol_char||''}",
     "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"#{@eol_char||''}",
     "\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">#{@eol_char||''}",
     "<html><head>#{@eol_char||''}",
     "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=#{@encoding||''}\" />#{@eol_char||''}",
     "<title>Difference</title>#{@eol_char||''}",
     "<style type=\"text/css\">#{@eol_char||''}" +
     " body {font-family: monospace;}#{@eol_char||''}" +
     " span.del {background: hotpink; border: thin inset;}#{@eol_char||''}" +
     " span.add {background: deepskyblue; font-weight: bolder; border: thin outset;}#{@eol_char||''}" +
     " span.before-change {background: yellow; border: thin inset;}#{@eol_char||''}" +
     " span.after-change {background: lime; font-weight: bolder; border: thin outset;}#{@eol_char||''}" +
     " li.entry .position {font-weight: bolder; margin-top: 0em; margin-bottom: 0em; padding-top: 0.5em; padding-bottom: 0em;}#{@eol_char||''}" +
     " li.entry .body {margin-top: 0em; margin-bottom: 0em; padding-top: 0em; padding-bottom: 0.5em;}#{@eol_char||''}" +
     " li.entry {border-top: thin solid gray;}#{@eol_char||''}" +
     "</style>#{@eol_char||''}",
     "</head><body><div>#{@eol_char||''}"]
  end
  def html_footer()
    [(@eol_char||"") + '</div></body></html>' + (@eol_char||"")]
  end
  HTMLEscapeDic = {'<'=>'&lt;', '>'=>'&gt;', '&'=>'&amp;', '  '=>'&nbsp;&nbsp;',
                   "\r\n" => "<br />\r\n", "\r" => "<br />\r", "\n" => "<br />\n"}
  HTMLEscapePat = /(\r\n|#{HTMLEscapeDic.keys.collect{|k|Regexp.quote(k)}.join('|')})/m
  def html_tags()
    {:outside_escape_dic  => HTMLEscapeDic,
     :outside_escape_pat  => HTMLEscapePat,
     :inside_escape_dic   => HTMLEscapeDic,
     :inside_escape_pat   => HTMLEscapePat,
     :start_digest_body   => '<ul>',
     :end_digest_body     => '</ul>',
     :start_entry         => '<li class="entry">',
     :end_entry           => '</blockquote></li>',
     :start_position      => '<p class="position">',
     :end_position        => '</p><blockquote class="body">',
     :start_prefix        => '<p class="body">',
     :end_prefix          => '',
     :start_postfix       => '',
     :end_postfix         => '</p>',
     :header              => html_header(),
     :footer              => html_footer(),
     :start_common        => '<span class="common">',
     :end_common          => '</span>',
     :start_del           => '<span class="del"><del>',
     :end_del             => '</del></span>',
     :start_add           => '<span class="add"><ins>',
     :end_add             => '</ins></span>',
     :start_before_change => '<span class="before-change"><del>',
     :end_before_change   => '</del></span>',
     :start_after_change  => '<span class="after-change"><ins>',
     :end_after_change    => '</ins></span>'}
  end
  def to_html(overriding_opts = nil, headfoot = true)
    tags = html_tags()
    tags.update(overriding_opts) if overriding_opts
    apply_style(tags, headfoot)
  end
  def to_html_digest(overriding_opts = nil, headfoot = true)
    tags = html_tags()
    tags.update(overriding_opts) if overriding_opts
    apply_style_digest(tags, headfoot)
  end

  # Manued
  def manued_header()
    ["defparentheses [ ]"        + (@eol_char||"\n"),
     "defdelete      /"          + (@eol_char||"\n"),
     "defswap        |"          + (@eol_char||"\n"),
     "defcomment     ;"          + (@eol_char||"\n"),
     "defescape      ~"          + (@eol_char||"\n"),
     "deforder       newer-last" + (@eol_char||"\n"),
     "defversion     0.9.5"      + (@eol_char||"\n")]
  end
  def manued_footer()
    []
  end
  ManuedInsideEscapeDic = {'~'=>'~~', '/'=>'~/', '['=>'~[', ']'=>'~]', ';'=>'~;'}
  ManuedInsideEscapePat = /(#{ManuedInsideEscapeDic.keys.collect{|k|Regexp.quote(k)}.join('|')})/m
  ManuedOutsideEscapeDic = {'~'=>'~~', '['=>'~['}
  ManuedOutsideEscapePat = /(#{ManuedOutsideEscapeDic.keys.collect{|k|Regexp.quote(k)}.join('|')})/m
  def manued_tags()
    {:inside_escape_dic   => ManuedInsideEscapeDic, 
     :inside_escape_pat   => ManuedInsideEscapePat,
     :outside_escape_dic  => ManuedOutsideEscapeDic,
     :outside_escape_pat  => ManuedOutsideEscapePat,
     :start_digest_body   => "----#{@eol_char||''}",
     :end_digest_body     => '',
     :start_entry         => '',
     :end_entry           => "----",
     :start_position      => '',
     :end_position        => "#{@eol_char||''}",
     :start_prefix        => '',
     :end_prefix          => '',
     :start_postfix       => '',
     :end_postfix         => "#{@eol_char||''}",
     :header              => manued_header(),
     :footer              => manued_footer(),
     :start_common        => '',
     :end_common          => '',
     :start_del           => '[',
     :end_del             => '/]',
     :start_add           => '[/',
     :end_add             => ']',
     :start_before_change => '[',
     :end_before_change   => '/',
     :start_after_change  => '',
     :end_after_change    => ']'
    }
  end
  def to_manued(overriding_opts = nil, headfoot = true)  # [ / ; ]
    tags = manued_tags()
    tags.update(overriding_opts) if overriding_opts
    apply_style(tags, headfoot)
  end
  def to_manued_digest(overriding_opts = nil, headfoot = true)  # [ / ; ]
    tags = manued_tags()
    # manued specific kludge: change should be [a/b] in inline, [a/][/b] in multi
    display = (overriding_opts and overriding_opts[:display]) || 'inline'
    if display == 'multi'
      tags.update({:end_before_change => '/]', :start_after_change => '[/'})
    end
    tags.update(overriding_opts) if overriding_opts
    apply_style_digest(tags, headfoot)
  end

  # wdiff-like
  def wdiff_header()
    []
  end
  def wdiff_footer()
    []
  end
  WDIFFEscapeDic = {'ThisRandomString' => 'ThisRandomString'}
  WDIFFEscapePat = /(\r\n|#{WDIFFEscapeDic.keys.collect{|k|Regexp.quote(k)}.join('|')})/m
  def wdiff_tags()
    {:outside_escape_dic  => WDIFFEscapeDic,
     :outside_escape_pat  => WDIFFEscapePat,
     :inside_escape_dic   => WDIFFEscapeDic,
     :inside_escape_pat   => WDIFFEscapePat,
     :start_digest_body   => "----#{@eol_char||''}",
     :end_digest_body     => '',
     :start_entry         => '',
     :end_entry           => "----",
     :start_position      => '',
     :end_position        => "#{@eol_char||''}",
     :start_prefix        => '',
     :end_prefix          => '',
     :start_postfix       => '',
     :end_postfix         => "#{@eol_char||''}",
     :header              => wdiff_header(),
     :footer              => wdiff_footer(),
     :start_common        => '',
     :end_common          => '',
     :start_del           => '[-',
     :end_del             => '-]',
     :start_add           => '{+',
     :end_add             => '+}',
     :start_before_change => '[-',
     :end_before_change   => '-]',
     :start_after_change  => '{+',
     :end_after_change    => '+}'}
  end
  def to_wdiff(overriding_opts = nil, headfoot = true)
    tags = wdiff_tags()
    tags.update(overriding_opts) if overriding_opts
    apply_style(tags)
  end
  def to_wdiff_digest(overriding_opts = nil, headfoot = true)
    tags = wdiff_tags()
    tags.update(overriding_opts) if overriding_opts
    apply_style_digest(tags, headfoot)
  end

  # user defined markup
  def user_header(); []; end
  def user_footer(); []; end
  UserEscapeDic = {'ThisRandomString' => 'ThisRandomString'}
  UserEscapePat = /(\r\n|#{UserEscapeDic.keys.collect{|k|Regexp.quote(k)}.join('|')})/m
  def user_tags()
    {:outside_escape_dic  => UserEscapeDic,
     :outside_escape_pat  => UserEscapePat,
     :inside_escape_dic   => UserEscapeDic,
     :inside_escape_pat   => UserEscapePat,
     :start_digest_body   => '',
     :end_digest_body     => '',
     :start_entry         => '',
     :end_entry           => '',
     :start_position      => '',
     :end_position        => ' ',
     :start_prefix        => '',
     :end_prefix          => '',
     :start_postfix       => '',
     :end_postfix         => '',
     :header              => user_header(),
     :footer              => user_footer(),
     :start_common        => '',
     :end_common          => '',
     :start_del           => '',
     :end_del             => '',
     :start_add           => '',
     :end_add             => '',
     :start_before_change => '',
     :end_before_change   => '',
     :start_after_change  => '',
     :end_after_change    => ''}
  end
  def to_user(overriding_opts = nil, headfoot = true)
    tags = user_tags()
    tags.update(overriding_opts) if overriding_opts
    apply_style(tags, headfoot)
  end
  def to_user_digest(overriding_opts = nil, headfoot = true)
    tags = user_tags()
    tags.update(overriding_opts) if overriding_opts
    apply_style_digest(tags, headfoot)
  end

  def to_debug()
  end

end
