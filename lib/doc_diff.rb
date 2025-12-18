# DocDiff: word/character-oriented text comparison utility
# Copyright (C) 2002-2011 Hisashi MORITA
# Requirements: Ruby (>= 2.0)
require 'docdiff/difference'
require 'docdiff/document'
require 'docdiff/view'

class DocDiff

  Author = "Copyright (C) 2002-2011 Hisashi MORITA.\n" +
           "diff library originates from Ruby/CVS by TANAKA Akira.\n"
  License = "This software is licensed under so-called modified BSD license.\n" +
            "See the document for detail.\n"
  SystemConfigFileName = File.join(File::Separator, "etc", "docdiff", "docdiff.conf")
  UserConfigFileName = File.join(ENV['HOME'], "etc", "docdiff", "docdiff.conf")
  AltUserConfigFileName = File.join(ENV['HOME'], ".docdiff", "docdiff.conf")
  XDGUserConfigFileName =
    if xdg_config_home = ENV['XDG_CONFIG_HOME'] && !xdg_config_home.empty?
      File.join(ENV['HOME'], xdg_config_home, "docdiff", "docdiff.conf")
    else
      File.join(ENV['HOME'], ".config", "docdiff", "docdiff.conf")
    end

  def initialize()
    @config = {}
  end
  attr_accessor :config

  def DocDiff.parse_options!(args, base_options: {})
    o = base_options.dup

    option_parser = OptionParser.new do |parser|
      parser.on(
        '--resolution=RESOLUTION',
        resolutions = ['line', 'word', 'char'],
        'specify resolution (granularity)',
        "#{resolutions.join('|')} (default: word)"
      ){|s| o[:resolution] = (s || "word")}
      parser.on('--line', 'same as --resolution=line'){o[:resolution] = "line"}
      parser.on('--word', 'same as --resolution=word'){o[:resolution] = "word"}
      parser.on('--char', 'same as --resolution=char'){o[:resolution] = "char"}

      parser.on(
        '--encoding=ENCODING',
        encodings = ['ASCII', 'EUC-JP', 'Shift_JIS', 'CP932', 'UTF-8', 'auto'],
        "specify character encoding",
        "#{encodings.join('|')} (default: auto)",
        "(try ASCII for single byte encodings such as ISO-8859)"
      ){|s| o[:encoding] = (s || "auto")}
      parser.on('--ascii', 'same as --encoding=ASCII'){o[:encoding] = "ASCII"}
      parser.on('--iso8859', 'same as --encoding=ASCII'){o[:encoding] = "ASCII"}
      parser.on('--iso8859x', 'same as --encoding=ASCII (deprecated)'){o[:encoding] = "ASCII"}
      parser.on('--eucjp', 'same as --encoding=EUC-JP'){o[:encoding] = "EUC-JP"}
      parser.on('--sjis', 'same as --encoding=Shift_JIS'){o[:encoding] = "Shift_JIS"}
      parser.on('--cp932', 'same as --encoding=CP932'){o[:encoding] = "CP932"}
      parser.on('--utf8', 'same as --encoding=UTF-8'){o[:encoding] = "UTF-8"}

      parser.on(
        '--eol=EOL',
        eols = ['CR','LF','CRLF','auto'],
        'specify end-of-line character',
        "#{eols.join('|')} (default: auto)",
      ){|s| o[:eol] = (s || "auto")}
      parser.on('--cr', 'same as --eol=CR'){o[:eol] = "CR"}
      parser.on('--lf', 'same as --eol=LF'){o[:eol] = "LF"}
      parser.on('--crlf', 'same as --eol=CRLF'){o[:eol] = "CRLF"}

      parser.on(
        '--format=FORMAT',
        formats = ['tty', 'manued', 'html', 'wdiff', 'stat', 'user'],
        'specify output format',
        "#{formats.join('|')} (default: html) (stat is deprecated)",
        '(user tags can be defined in config file)'
      ){|s| o[:format] = (s || "manued")}
      parser.on('--tty', 'same as --format=tty'){o[:format] = "tty"}
      parser.on('--manued', 'same as --format=manued'){o[:format] = "manued"}
      parser.on('--html', 'same as --format=html'){o[:format] = "html"}
      parser.on('--wdiff', 'same as --format=wdiff'){o[:format] = "wdiff"}
      parser.on('--stat', 'same as --format=stat (not implemented) (deprecated)'){o[:format] = "stat"}

      parser.on(
        '--label LABEL', '-L LABEL',
        'use label instead of file name (not implemented; exists for compatibility with diff)'
      ){|s1, s2| o[:label1], o[:label2] = s1, s2}

      parser.on('--digest', 'digest output, do not show all'){o[:digest] = true}
      parser.on('--summary', 'same as --digest'){o[:digest] = true}

      parser.on(
        '--display=DISPLAY',
        display_types = ['inline', 'block', 'multi'],
        'specify presentation type (effective only with digest; experimental feature)',
        "#{display_types.join('|')} (default: inline) (multi is deprecated)",
      ){|s| o[:display] ||= s.downcase}

      parser.on('--cache', 'use file cache (not implemented) (deprecated)'){o[:cache] = true}
      parser.on(
        '--pager=PAGER', String,
        'specify pager (if available, $DOCDIFF_PAGER is used by default)'
      ){|s| o[:pager] = s}
      parser.on('--no-pager', 'do not use pager'){o[:pager] = false}
      parser.on('--config-file=FILE', String, 'specify config file to read'){|s| o[:config_file] = s}
      parser.on('--no-config-file', 'do not read config files'){o[:no_config_file] = true}
      parser.on('--verbose', 'run verbosely (not well-supported) (deprecated)'){o[:verbose] = true}

      parser.on('--help', 'show this message'){puts parser; exit(0)}
      parser.on('--version', 'show version'){puts Docdiff::VERSION; exit(0)}
      parser.on('--license', 'show license (deprecated)'){puts DocDiff::License; exit(0)}
      parser.on('--author', 'show author(s) (deprecated)'){puts DocDiff::Author; exit(0)}

      parser.on_tail(
        "When invoked as worddiff or chardiff, resolution will be set accordingly.",
        "Config files: /etc/docdiff/docdiff.conf, ~/.config/docdiff/docdiff.conf (or ~/etc/docdiff/docdiff.conf (deprecated))"
      )
    end

    option_parser.parse!(args)
    o
  end

  def DocDiff.parse_config_file_content(content)
    result = {}
    return result if content.size <= 0
    lines = content.dup.split(/\r\n|\r|\n/).compact
    lines.collect!{|line| line.sub(/#.*$/, '')}
    lines.collect!{|line| line.strip}
    lines.delete_if{|line| line == ""}
    lines.each{|line|
      raise 'line does not include " = ".' unless /[\s]+=[\s]+/.match line
      name_src, value_src = line.split(/[\s]+=[\s]+/)
      raise "Invalid name: #{name_src.inspect}" if (/\s/.match name_src)
      raise "Invalid value: #{value_src.inspect}" unless value_src.kind_of?(String)
      name  = name_src.intern
      value = value_src
      value = true if ['on','yes','true'].include? value_src.downcase
      value = false if ['off','no','false'].include? value_src.downcase
      value = value_src.to_i if /^[0-9]+$/.match value_src
      result[name] = value
    }
    result
  end

  def compare_by_line(doc1, doc2)
    Difference.new(doc1.split_to_line, doc2.split_to_line)
  end

  def compare_by_line_word(doc1, doc2)
    lines = compare_by_line(doc1, doc2)
    words = Difference.new
    lines.each{|line|
      if line.first == :change_elt
        before_change = Document.new(line[1].join,
                                     doc1.encoding, doc1.eol)
        after_change  = Document.new(line[2].join,
                                     doc2.encoding, doc2.eol)
        Difference.new(before_change.split_to_word,
                       after_change.split_to_word).each{|word|
          words << word
        }
      else  # :common_elt_elt, :del_elt, or :add_elt
        words << line
      end
    }
    words
  end

  # i know this implementation of recursion is so lame...
  def compare_by_line_word_char(doc1, doc2)
    lines = compare_by_line(doc1, doc2)
    lines_and_words = Difference.new
    lines.each{|line|
      if line.first == :change_elt
        before_change = Document.new(line[1].join,
                                     doc1.encoding, doc1.eol)
        after_change  = Document.new(line[2].join,
                                     doc2.encoding, doc2.eol)
        Difference.new(before_change.split_to_word,
                       after_change.split_to_word).each{|word|
          lines_and_words << word
        }
      else  # :common_elt_elt, :del_elt, or :add_elt
        lines_and_words << line
      end
    }
    lines_words_and_chars = Difference.new
    lines_and_words.each{|line_or_word|
      if line_or_word.first == :change_elt
        before_change = Document.new(line_or_word[1].join, doc1.encoding, doc1.eol)
        after_change  = Document.new(line_or_word[2].join, doc2.encoding, doc2.eol)
        Difference.new(before_change.split_to_char, after_change.split_to_char).each{|char|
          lines_words_and_chars << char
        }
      else  # :common_elt_elt, :del_elt, or :add_elt
        lines_words_and_chars << line_or_word
      end
    }
    lines_words_and_chars
  end

  def run(doc1, doc2, option)
    raise "option is nil" if option.nil?
    raise "option[:resolution] is nil" if option[:resolution].nil?
    raise "option[:format] is nil" if option[:format].nil?
    case
    when doc1.class == Document && doc2.class == Document # OK
    when doc1.encoding != nil && doc2.encoding != nil     # OK
    when doc1.encoding == doc2.encoding && doc1.eol == doc2.eol # OK
    else
      raise("Error!  Blame the author (doc1: #{doc1.encoding}, #{doc1.eol}, doc2: #{doc2.encoding}, #{doc2.eol}).")
    end

    case option[:resolution]
    when "line"; then difference = compare_by_line(doc1, doc2)
    when "word"; then difference = compare_by_line_word(doc1, doc2)
    when "char"; then difference = compare_by_line_word_char(doc1, doc2)
    else
      raise "Unsupported resolution: #{option[:resolution].inspect}"
    end
    view = View.new(difference, doc1.encoding, doc1.eol)
    user_tags = {:start_common        => (@config[:tag_common_start] ||= ''),
                 :end_common          => (@config[:tag_common_end] ||= ''),
                 :start_del           => (@config[:tag_del_start] ||= ''),
                 :end_del             => (@config[:tag_del_end] ||= ''),
                 :start_add           => (@config[:tag_add_start] ||= ''),
                 :end_add             => (@config[:tag_add_end] ||= ''),
                 :start_before_change => (@config[:tag_change_before_start] ||= ''),
                 :end_before_change   => (@config[:tag_change_before_end] ||= ''),
                 :start_after_change  => (@config[:tag_change_after_start] ||= ''),
                 :end_after_change    => (@config[:tag_change_after_end] ||= '')}
    case option[:digest]
    when true
      case option[:format]
      when "tty";      then result = view.to_tty_digest(option)
      when "html";     then result = view.to_html_digest(option)
      when "manued";   then result = view.to_manued_digest(option)
      when "wdiff";    then result = view.to_wdiff_digest(option)
      when "stat";     then result = view.to_stat(option)
      when "user";     then result = view.to_user_digest(user_tags)
      else
        raise "Unsupported output format: #{option[:format].inspect}."
      end
    when false
      case option[:format]
      when "tty";      then result = view.to_tty(option)
      when "html";     then result = view.to_html(option)
      when "manued";   then result = view.to_manued(option)
      when "wdiff";    then result = view.to_wdiff(option)
      when "stat";     then result = view.to_stat(option)
      when "user";     then result = view.to_user(user_tags)
      else
        raise "Unsupported output format: #{option[:format].inspect}."
      end
    end
    result.join
  end

  def process_config_file(filename)
    file_content = nil
    begin
      File.open(filename, "r"){|f| file_content = f.read}
    rescue Errno::ENOENT
      message = "config file not found so not read."
    ensure
      if file_content != nil
        self.config.update(DocDiff.parse_config_file_content(file_content))
      end
    end
    message
  end

  def print_or_write_to_pager(content, pager)
    if STDOUT.tty? && pager.is_a?(String) && !pager.empty?
      IO.popen(pager, "w"){|f| f.print content}
    else
      print content
    end
  end
end  # class DocDiff
