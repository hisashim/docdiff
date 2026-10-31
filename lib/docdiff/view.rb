#!/usr/bin/ruby

class String
  def scan_lines(eol)
    case eol
    when nil, "NONE" then scan(/\A.+\Z/m)
    when "CR" then        scan(/.*?\r|[^\r]+\Z/m)
    when "LF" then        scan(/.*?\n|[^\n]+\Z/m)
    when "CRLF" then      scan(/.*?\r\n|.+\Z/m)
    else raise "#{eol} is not supported.\n"
    end
  end

  def scan_eols(eol)
    case eol
    when nil, "NONE" then []
    when "CR" then        scan(/\r/m)
    when "LF" then        scan(/\n/m)
    when "CRLF" then      scan(/\r\n/m)
    else raise "#{eol} is not supported.\n"
    end
  end
end

class DocDiff
  class Difference < Array
    def to_view(encoding, eol)
      View.new(self, encoding, eol, file_names)
    end
  end

  class View
    # EOL_CHARS_PAT = Regexp.new(/\r\n|\r(?!\n)|(?:\A|[^\r])\n/m)

    def initialize(difference, encoding, eol, file_names = [:dummy, :dummy])
      @difference = difference
      @encoding = encoding
      @eol = eol
      @eol_char = { "CR" => "\r", "LF" => "\n", "CRLF" => "\r\n" }[@eol]
      # if CharString::EOLChars[@eol]
      #   @eol_char = CharString::EOLChars[@eol].eol_char
      # else
      #   @eol_char = nil
      # end
      @file_names = file_names
    end

    attr_reader :file_names

    def difference_whole
      @difference
    end

    def difference_digest
    end

    def escape_inside(str, tags)
      str.gsub(tags[:inside_escape_pat]) do |m|
        if (replacement = tags[:inside_escape_dic][m])
          replacement
        else
          m
        end
      end
    end

    def escape_outside(str, tags)
      str.gsub(tags[:outside_escape_pat]) do |m|
        if (replacement = tags[:outside_escape_dic][m])
          replacement
        else
          m
        end
      end
    end

    def apply_style(tags, headfoot = true)
      result = []
      @difference.each do |block|
        operation = block.first
        source = (block[1] || []).join
        target = (block[2] || []).join
        case operation
        when :common_elt_elt
          result << (tags[:start_common] + escape_outside(source, tags) + tags[:end_common])
        when :change_elt
          result << (tags[:start_before_change] + escape_inside(source, tags) + tags[:end_before_change] +
                     tags[:start_after_change]  + escape_inside(target, tags) + tags[:end_after_change])
        when :del_elt
          result << (tags[:start_del] + escape_inside(source, tags) + tags[:end_del])
        when :add_elt
          result << (tags[:start_add] + escape_inside(target, tags) + tags[:end_add])
        else
          raise "invalid attribute: #{block.first}\n"
        end
      end
      if headfoot == true
        result = tags[:header] + result + tags[:footer]
      end
      result.delete_if { |elem| elem == "" }
    end

    def format_line_range(start, span: 1, paren: false)
      range =
        if span > 1
          "LL#{start}-#{start + span - 1}"
        else
          "L#{start}"
        end
      if paren
        "(#{range})"
      else
        range
      end
    end

    CONTEXT_PRE_LENGTH  = 32
    CONTEXT_POST_LENGTH = 32
    CONTEXT_PRE_PATTERN =
      Regexp.new(".{0,#{CONTEXT_PRE_LENGTH}}\\Z", Regexp::MULTILINE)
    CONTEXT_POST_PATTERN =
      Regexp.new("\\A.{0,#{CONTEXT_POST_LENGTH}}", Regexp::MULTILINE)

    def digest_context(index)
      context_pre =
        if index == 0
          "" # no preceding context for the first entry
        else
          (@difference[index - 1][1] || []).join.scan(CONTEXT_PRE_PATTERN).join
        end
      context_post =
        if (index + 1) == @difference.size
          "" # no following context for the last entry
        else
          (@difference[index + 1][1] || []).join.scan(CONTEXT_POST_PATTERN).join
        end
      [context_pre, context_post]
    end

    def format_digest_entry(
      operation, source, target,
      line1:, line2:, context_pre:, context_post:, display:, tags:
    )
      span1 = source.scan_lines(@eol).size # source lines involved
      span2 = target.scan_lines(@eol).size # target lines involved

      elements =
        case operation
        when :change_elt
          before = tags[:start_before_change] + escape_inside(source, tags) + tags[:end_before_change]
          after = tags[:start_after_change] + escape_inside(target, tags) + tags[:end_after_change]
          {
            source_range: format_line_range(line1, span: span1),
            target_range: format_line_range(line2, span: span2),
            inline: before + after,
            source_block: before,
            target_block: after,
          }
        when :del_elt
          del = tags[:start_del] + escape_outside(source, tags) + tags[:end_del]
          {
            source_range: format_line_range(line1, span: span1),
            target_range: format_line_range(line2, paren: true),
            inline: del,
            source_block: escape_inside(source, tags),
            target_block: del,
          }
        when :add_elt
          add = tags[:start_add] + escape_outside(target, tags) + tags[:end_add]
          {
            source_range: format_line_range(line1, paren: true),
            target_range: format_line_range(line2, span: span2),
            inline: add,
            source_block: escape_inside(source, tags),
            target_block: add,
          }
        else
          raise "invalid attribute: #{block.first}\n"
        end

      pre = tags[:start_prefix] + escape_outside(context_pre, tags) + tags[:end_prefix]
      post = tags[:start_postfix] + escape_outside(context_post, tags) + tags[:end_postfix]

      head =
        tags[:start_entry] + tags[:start_position] +
        "#{elements[:source_range]}, #{elements[:target_range]}" +
        tags[:end_position]
      body =
        case display
        when "inline"
          pre + elements[:inline] + post
        when /block|multi/
          pre + elements[:source_block] + post + pre + elements[:target_block] + post
        else
          raise "Unsupported display type: #{display}"
        end
      foot =
        tags[:end_entry] + (@eol_char || "")

      head + body + foot
    end

    def apply_style_digest(tags, headfoot = true)
      display = (tags and tags[:display]) || "inline"
      result = []
      line1 = 1 # doc1 line number
      line2 = 1 # doc2 line number
      @difference.each_with_index do |entry, i|
        source = (entry[1] || []).join
        target = (entry[2] || []).join

        unless entry.first == :common_elt_elt # skip common part
          context_pre, context_post = digest_context(i)
          result << format_digest_entry(
            entry.first,
            source,
            target,
            line1: line1,
            line2: line2,
            context_pre: context_pre,
            context_post: context_post,
            display: display,
            tags: tags,
          )
        end
        line1 += source.scan_eols(@eol).size
        line2 += target.scan_eols(@eol).size
      end
      result.unshift(tags[:start_digest_body])
      result.push(tags[:end_digest_body])
      result = tags[:header] + result + tags[:footer] if headfoot == true
      result.delete_if { |elem| elem == "" }
    end

    def source_lines
      if @source_lines.nil?
        @source_lines = @difference.collect { |entry| entry[1] }.join.scan_lines(@eol)
      end
      @source_lines
    end

    def target_lines
      if @target_lines.nil?
        @target_lines = @difference.collect { |entry| entry[2] }.join.scan_lines(@eol)
      end
      @target_lines
    end

    # tty (terminal)
    def tty_header
      []
    end

    def tty_footer
      []
    end
    TTY_ESCAPE_DIC = { "ThisRandomString" => "ThisRandomString" }
    TTY_ESCAPE_PAT = /(#{TTY_ESCAPE_DIC.keys.map { |k| Regexp.quote(k) }.join("|")})/m
    def tty_tags
      {
        outside_escape_dic:  TTY_ESCAPE_DIC,
        outside_escape_pat:  TTY_ESCAPE_PAT,
        inside_escape_dic:   TTY_ESCAPE_DIC,
        inside_escape_pat:   TTY_ESCAPE_PAT,
        start_digest_body:   "----#{@eol_char || ""}",
        end_digest_body:     "",
        start_entry:         "",
        end_entry:           "----",
        start_position:      "",
        end_position:        (@eol_char || "").to_s,
        start_prefix:        "",
        end_prefix:          "",
        start_postfix:       "",
        end_postfix:         (@eol_char || "").to_s,
        header:              tty_header,
        footer:              tty_footer,
        start_common:        "",
        end_common:          "",
        start_del:           "\033[7;4;31m", # Inverted, Underlined, Red
        end_del:             "\033[0m",
        start_add:           "\033[7;1;34m", # Inverted, Bold, Blue
        end_add:             "\033[0m",
        start_before_change: "\033[7;4;33m", # Inverted, Underlined, Yellow
        end_before_change:   "\033[0m",
        start_after_change:  "\033[7;1;32m", # Inverted, Bold, Green
        end_after_change:    "\033[0m",
      }
    end

    def to_tty(overriding_opts = nil, headfoot = true) # color escape sequence
      tags = tty_tags
      tags.update(overriding_opts) if overriding_opts
      apply_style(tags, headfoot)
    end

    def to_tty_digest(overriding_opts = nil, headfoot = true)
      tags = tty_tags
      tags.update(overriding_opts) if overriding_opts
      apply_style_digest(tags, headfoot)
    end

    # HTML (XHTML)
    def html_header
      [
        "<?xml version=\"1.0\" encoding=\"#{@encoding || ""}\"?>#{@eol_char || ""}",
        "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"#{@eol_char || ""}",
        "\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">#{@eol_char || ""}",
        "<html><head>#{@eol_char || ""}",
        "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=#{@encoding || ""}\" />#{@eol_char || ""}",
        "<title>Difference</title>#{@eol_char || ""}",
        "<style type=\"text/css\">#{@eol_char || ""} " \
          "body {font-family: monospace;}#{@eol_char || ""} " \
          "span.del {background: hotpink; border: thin inset;}#{@eol_char || ""} " \
          "span.add {background: deepskyblue; font-weight: bolder; border: thin outset;}#{@eol_char || ""} " \
          "span.before-change {background: yellow; border: thin inset;}#{@eol_char || ""} " \
          "span.after-change {background: lime; font-weight: bolder; border: thin outset;}#{@eol_char || ""} " \
          "li.entry .position {font-weight: bolder; margin-top: 0em; margin-bottom: 0em; padding-top: 0.5em; padding-bottom: 0em;}#{@eol_char || ""} " \
          "li.entry .body {margin-top: 0em; margin-bottom: 0em; padding-top: 0em; padding-bottom: 0.5em;}#{@eol_char || ""} " \
          "li.entry {border-top: thin solid gray;}#{@eol_char || ""}" \
          "</style>#{@eol_char || ""}",
        "</head><body><div>#{@eol_char || ""}",
      ]
    end

    def html_footer
      [(@eol_char || "") + "</div></body></html>" + (@eol_char || "")]
    end
    HTML_ESCAPE_DIC = {
      "<"    => "&lt;",
      ">"    => "&gt;",
      "&"    => "&amp;",
      "  "   => "&nbsp;&nbsp;",
      "\r\n" => "<br />\r\n",
      "\r"   => "<br />\r",
      "\n"   => "<br />\n",
    }
    HTML_ESCAPE_PAT = /(#{HTML_ESCAPE_DIC.keys.map { |k| Regexp.quote(k) }.join("|")})/m
    def html_tags
      {
        outside_escape_dic:  HTML_ESCAPE_DIC,
        outside_escape_pat:  HTML_ESCAPE_PAT,
        inside_escape_dic:   HTML_ESCAPE_DIC,
        inside_escape_pat:   HTML_ESCAPE_PAT,
        start_digest_body:   "<ul>",
        end_digest_body:     "</ul>",
        start_entry:         '<li class="entry">',
        end_entry:           "</blockquote></li>",
        start_position:      '<p class="position">',
        end_position:        '</p><blockquote class="body">',
        start_prefix:        '<p class="body">',
        end_prefix:          "",
        start_postfix:       "",
        end_postfix:         "</p>",
        header:              html_header,
        footer:              html_footer,
        start_common:        '<span class="common">',
        end_common:          "</span>",
        start_del:           '<span class="del"><del>',
        end_del:             "</del></span>",
        start_add:           '<span class="add"><ins>',
        end_add:             "</ins></span>",
        start_before_change: '<span class="before-change"><del>',
        end_before_change:   "</del></span>",
        start_after_change:  '<span class="after-change"><ins>',
        end_after_change:    "</ins></span>",
      }
    end

    def to_html(overriding_opts = nil, headfoot = true)
      tags = html_tags
      tags.update(overriding_opts) if overriding_opts
      apply_style(tags, headfoot)
    end

    def to_html_digest(overriding_opts = nil, headfoot = true)
      tags = html_tags
      tags.update(overriding_opts) if overriding_opts
      apply_style_digest(tags, headfoot)
    end

    # Manued
    def manued_header
      [
        "defparentheses [ ]"        + (@eol_char || "\n"),
        "defdelete      /"          + (@eol_char || "\n"),
        "defswap        |"          + (@eol_char || "\n"),
        "defcomment     ;"          + (@eol_char || "\n"),
        "defescape      ~"          + (@eol_char || "\n"),
        "deforder       newer-last" + (@eol_char || "\n"),
        "defversion     0.9.5"      + (@eol_char || "\n"),
      ]
    end

    def manued_footer
      []
    end
    MANUED_INSIDE_ESCAPE_DIC = { "~" => "~~", "/" => "~/", "[" => "~[", "]" => "~]", ";" => "~;" }
    MANUED_INSIDE_ESCAPE_PAT = /(#{MANUED_INSIDE_ESCAPE_DIC.keys.map { |k| Regexp.quote(k) }.join("|")})/m
    MANUED_OUTSIDE_ESCAPE_DIC = { "~" => "~~", "[" => "~[" }
    MANUED_OUTSIDE_ESCAPE_PAT = /(#{MANUED_OUTSIDE_ESCAPE_DIC.keys.map { |k| Regexp.quote(k) }.join("|")})/m
    def manued_tags
      {
        inside_escape_dic:   MANUED_INSIDE_ESCAPE_DIC,
        inside_escape_pat:   MANUED_INSIDE_ESCAPE_PAT,
        outside_escape_dic:  MANUED_OUTSIDE_ESCAPE_DIC,
        outside_escape_pat:  MANUED_OUTSIDE_ESCAPE_PAT,
        start_digest_body:   "----#{@eol_char || ""}",
        end_digest_body:     "",
        start_entry:         "",
        end_entry:           "----",
        start_position:      "",
        end_position:        (@eol_char || "").to_s,
        start_prefix:        "",
        end_prefix:          "",
        start_postfix:       "",
        end_postfix:         (@eol_char || "").to_s,
        header:              manued_header,
        footer:              manued_footer,
        start_common:        "",
        end_common:          "",
        start_del:           "[",
        end_del:             "/]",
        start_add:           "[/",
        end_add:             "]",
        start_before_change: "[",
        end_before_change:   "/",
        start_after_change:  "",
        end_after_change:    "]",
      }
    end

    def to_manued(overriding_opts = nil, headfoot = true) # [ / ; ]
      tags = manued_tags
      tags.update(overriding_opts) if overriding_opts
      apply_style(tags, headfoot)
    end

    def to_manued_digest(overriding_opts = nil, headfoot = true) # [ / ; ]
      tags = manued_tags
      # manued specific kludge: change should be [a/b] in inline, [a/][/b] in multi
      display = (overriding_opts and overriding_opts[:display]) || "inline"
      if /block|multi/.match(display)
        tags.update({ end_before_change: "/]", start_after_change: "[/" })
      end
      tags.update(overriding_opts) if overriding_opts
      apply_style_digest(tags, headfoot)
    end

    # wdiff-like
    def wdiff_header
      []
    end

    def wdiff_footer
      []
    end
    WDIFF_ESCAPE_DIC = { "ThisRandomString" => "ThisRandomString" }
    WDIFF_ESCAPE_PAT = /(#{WDIFF_ESCAPE_DIC.keys.map { |k| Regexp.quote(k) }.join("|")})/m
    def wdiff_tags
      {
        outside_escape_dic:  WDIFF_ESCAPE_DIC,
        outside_escape_pat:  WDIFF_ESCAPE_PAT,
        inside_escape_dic:   WDIFF_ESCAPE_DIC,
        inside_escape_pat:   WDIFF_ESCAPE_PAT,
        start_digest_body:   "----#{@eol_char || ""}",
        end_digest_body:     "",
        start_entry:         "",
        end_entry:           "----",
        start_position:      "",
        end_position:        (@eol_char || "").to_s,
        start_prefix:        "",
        end_prefix:          "",
        start_postfix:       "",
        end_postfix:         (@eol_char || "").to_s,
        header:              wdiff_header,
        footer:              wdiff_footer,
        start_common:        "",
        end_common:          "",
        start_del:           "[-",
        end_del:             "-]",
        start_add:           "{+",
        end_add:             "+}",
        start_before_change: "[-",
        end_before_change:   "-]",
        start_after_change:  "{+",
        end_after_change:    "+}",
      }
    end

    def to_wdiff(overriding_opts = nil, headfoot = true)
      tags = wdiff_tags
      tags.update(overriding_opts) if overriding_opts
      apply_style(tags)
    end

    def to_wdiff_digest(overriding_opts = nil, headfoot = true)
      tags = wdiff_tags
      tags.update(overriding_opts) if overriding_opts
      apply_style_digest(tags, headfoot)
    end

    # user defined markup
    def user_header
      []
    end

    def user_footer
      []
    end

    USER_ESCAPE_DIC = { "ThisRandomString" => "ThisRandomString" }
    USER_ESCAPE_PAT = /(#{USER_ESCAPE_DIC.keys.map { |k| Regexp.quote(k) }.join("|")})/m
    def user_tags
      {
        outside_escape_dic:  USER_ESCAPE_DIC,
        outside_escape_pat:  USER_ESCAPE_PAT,
        inside_escape_dic:   USER_ESCAPE_DIC,
        inside_escape_pat:   USER_ESCAPE_PAT,
        start_digest_body:   "",
        end_digest_body:     "",
        start_entry:         "",
        end_entry:           "",
        start_position:      "",
        end_position:        " ",
        start_prefix:        "",
        end_prefix:          "",
        start_postfix:       "",
        end_postfix:         "",
        header:              user_header,
        footer:              user_footer,
        start_common:        "",
        end_common:          "",
        start_del:           "",
        end_del:             "",
        start_add:           "",
        end_add:             "",
        start_before_change: "",
        end_before_change:   "",
        start_after_change:  "",
        end_after_change:    "",
      }
    end

    def to_user(overriding_opts = nil, headfoot = true)
      tags = user_tags
      tags.update(overriding_opts) if overriding_opts
      apply_style(tags, headfoot)
    end

    def to_user_digest(overriding_opts = nil, headfoot = true)
      tags = user_tags
      tags.update(overriding_opts) if overriding_opts
      apply_style_digest(tags, headfoot)
    end

    def to_debug
    end
  end
end
