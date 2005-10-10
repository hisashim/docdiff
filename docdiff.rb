#!/usr/bin/ruby
# DocDiff: word/char-oriented text comparison utility
# 2002-06-27 Thu ... 2005-xx-xx xxx
# Hisashi MORITA
# requirement for runtime: Ruby (> 1.6)
# requirement for testing: above plus Uconv by Yoshidam

require 'docdiff/difference'
require 'docdiff/document'
require 'docdiff/view'
require 'optparse'

class DocDiff

  AppVersion = '0.3.3'
  Author = "Copyright (C) 2002-2005 Hisashi MORITA.\n" +
           "diff library originates from Ruby/CVS by TANAKA Akira.\n"
  License = "This software is licensed under so-called modified BSD license.\n" +
            "See the document for detail.\n"
  SystemConfigFileName = File.join(File::Separator, "etc", "docdiff", "docdiff.conf")
  UserConfigFileName = File.join(ENV['HOME'], "etc", "docdiff", "docdiff.conf")
  AltUserConfigFileName = File.join(ENV['HOME'], ".docdiff", "docdiff.conf")

  def initialize()
    @config = {}
  end
  attr_accessor :config

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
        before_change = Document.new(line[1].to_s,
                                     doc1.encoding, doc1.eol)
        after_change  = Document.new(line[2].to_s,
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
        before_change = Document.new(line[1].to_s,
                                     doc1.encoding, doc1.eol)
        after_change  = Document.new(line[2].to_s,
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
        before_change = Document.new(line_or_word[1].to_s, doc1.encoding, doc1.eol)
        after_change  = Document.new(line_or_word[2].to_s, doc2.encoding, doc2.eol)
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
      when "html";    then result = view.to_html_digest(option)
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
    result.to_s
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

end  # class DocDiff


if $0 == __FILE__

  # do_config_stuff

  default_config = {
    :resolution    => "word",
    :encoding      => "auto",
    :eol           => "auto",
    :format        => "html",
    :cache         => true,
    :digest        => false,
    :verbose       => false
  }

  clo = command_line_options = {}

  # if invoked as "worddiff" or "chardiff",
  # appropriate resolution is set respectively.
  case File.basename($0, ".*")
  when "worddiff" then; clo[:resolution] = "word"
  when "chardiff" then; clo[:resolution] = "char"
  end

  ARGV.options {|o|
    o.def_option('--resolution=RESOLUTION',
                 possible_resolutions = ['line', 'word', 'char'],
                 'specify resolution (granularity)',
                 possible_resolutions.join('|') + ' (default is word)'
                ){|clo[:resolution]| clo[:resolution] ||= "word"}
    o.def_option('--line', 'set resolution to line'){clo[:resolution] = "line"}
    o.def_option('--word', 'set resolution to word'){clo[:resolution] = "word"}
    o.def_option('--char', 'set resolution to char'){clo[:resolution] = "char"}

    o.def_option('--encoding=ENCODING',
                 possible_encodings = ['ASCII','EUC-JP','Shift_JIS','UTF-8','auto'],
                 'specify character encoding',
                 possible_encodings.join('|'), '(default is auto)'
                ){|clo[:encoding]| clo[:encoding] ||= "auto"}
    o.def_option('--ascii', 'same as --encoding=ASCII'){clo[:encoding] = "ASCII"}
    o.def_option('--eucjp', 'same as --encoding=EUC-JP'){clo[:encoding] = "EUC-JP"}
    o.def_option('--sjis', 'same as --encoding=Shift_JIS'){clo[:encoding] = "Shift_JIS"}
    o.def_option('--utf8', 'same as --encoding=UTF-8'){clo[:encoding] = "UTF-8"}

    o.def_option('--eol=EOL',
                 possible_eols = ['CR','LF','CRLF','auto'],
                 'specify end-of-line character',
                 possible_eols.join('|') + ' (default is auto)'
                ){|clo[:eol]| clo[:eol] ||= "auto"}
    o.def_option('--cr', 'same as --eol=CR'){clo[:eol] = "CR"}
    o.def_option('--lf', 'same as --eol=LF'){clo[:eol] = "LF"}
    o.def_option('--crlf', 'same as --eol=CRLF'){clo[:eol] = "CRLF"}

    o.def_option('--format=FORMAT',
                 possible_formats = ['tty','manued','html','wdiff','stat','user'],
                 'specify output format',
                 possible_formats.join('|'),
                 "(default is html)",
                 '(user tags can be defined in config file)'
                ){|clo[:format]| clo[:format] ||= "manued"}
    o.def_option('--tty', 'same as --format=tty'){clo[:format] = "tty"}
    o.def_option('--manued', 'same as --format=manued'){clo[:format] = "manued"}
    o.def_option('--html', 'same as --format=html'){clo[:format] = "html"}
    o.def_option('--wdiff', 'same as --format=wdiff'){clo[:format] = "wdiff"}
    o.def_option('--stat', 'same as --format=stat (not supported yet)'){clo[:format] = "stat"}

    o.def_option('--label LABEL', '-L LABEL',
                 'Use label instead of filename (not supported yet)'){|clo[:label1], clo[:label2]|}

    o.def_option('--digest', 'digest output, do not show all'){clo[:digest] = true}
    o.def_option('--summary', 'same as --digest'){clo[:digest] = true}
    o.def_option('--cache', 'use file cache (not supported yet)'){clo[:cache] = true}
    o.def_option('--no-config-file',
                 'do not read config files'){clo[:no_config_file] = true}
    o.def_option('--verbose', 'run verbosely (not supported yet)'){clo[:verbose] = true}

    o.def_option('--help', 'show this message'){puts o; exit(0)}
    o.def_option('--version', 'show version'){puts DocDiff::AppVersion; exit(0)}
    o.def_option('--license', 'show license'){puts DocDiff::License; exit(0)}
    o.def_option('--author', 'show author(s)'){puts DocDiff::Author; exit(0)}

    o.on_tail("When invoked as worddiff or chardiff, resolution will be set accordingly.",
              "Config files: /etc/docdiff/docdiff.conf, ~/etc/docdiff/docdiff.conf")

    o.parse!
  } or exit(1)

  docdiff = DocDiff.new()
  docdiff.config.update(default_config)
  unless clo[:no_config_file] == true # process_commandline_option
    message = docdiff.process_config_file(DocDiff::SystemConfigFileName)
    if clo[:verbose] == true || docdiff.config[:verbose] == true
      STDERR.print message
    end
#    message = docdiff.process_config_file(DocDiff::UserConfigFileName)
    case
    when File.exist?(DocDiff::UserConfigFileName) && File.exist?(DocDiff::AltUserConfigFileName)
      raise "#{DocDiff::UserConfigFileName} and #{DocDiff::AltUserConfigFileName} cannot be used at the same time.  Remove or rename either one."
    when File.exist?(DocDiff::UserConfigFileName)
      message = docdiff.process_config_file(DocDiff::UserConfigFileName)
    when File.exist?(DocDiff::AltUserConfigFileName)
      message = docdiff.process_config_file(DocDiff::AltUserConfigFileName)
    end
    if clo[:verbose] == true || docdiff.config[:verbose] == true
      STDERR.print message
    end
  end
  docdiff.config.update(clo)

  # config stuff done

  # process the documents

  file1_content = nil
  file2_content = nil
  raise "Try `#{File.basename($0)} --help' for more information." if ARGV[0].nil?
  raise "Specify at least 2 target files." unless ARGV[0] && ARGV[1]
  raise "No such file: #{ARGV[0]}." unless FileTest.exist?(ARGV[0])
  raise "No such file: #{ARGV[1]}." unless FileTest.exist?(ARGV[1])
  raise "#{ARGV[0]} is not a file." unless FileTest.file?(ARGV[0])
  raise "#{ARGV[1]} is not a file." unless FileTest.file?(ARGV[1])
  File.open(ARGV[0], "r"){|f| file1_content = f.read}
  File.open(ARGV[1], "r"){|f| file2_content = f.read}

  doc1 = nil
  doc2 = nil

  encoding1 = docdiff.config[:encoding]
  encoding2 = docdiff.config[:encoding]
  eol1 = docdiff.config[:eol]
  eol2 = docdiff.config[:eol]

  if docdiff.config[:encoding] == "auto"
    encoding1 = CharString.guess_encoding(file1_content)
    encoding2 = CharString.guess_encoding(file2_content)
    case
    when (encoding1 == "UNKNOWN" or encoding2 == "UNKNOWN")
      raise "Document encoding unknown (#{encoding1}, #{encoding2})."
    when encoding1 != encoding2
      raise "Document encoding mismatch (#{encoding1}, #{encoding2})."
    end
  end

  if docdiff.config[:eol] == "auto"
    eol1 = CharString.guess_eol(file1_content)
    eol2 = CharString.guess_eol(file2_content)
    case
    when (eol1.nil? or eol2.nil?)
      raise "Document eol is nil (#{eol1.inspect}, #{eol2.inspect}).  The document might be empty."
    when (eol1 == 'UNKNOWN' or eol2 == 'UNKNOWN')
      raise "Document eol unknown (#{eol1.inspect}, #{eol2.inspect})."
    when (eol1 != eol2)
      raise "Document eol mismatch (#{eol1}, #{eol2})."
    end
  end

  doc1 = Document.new(file1_content, encoding1, eol1)
  doc2 = Document.new(file2_content, encoding2, eol2)

  output = docdiff.run(doc1, doc2,
                        {:resolution => docdiff.config[:resolution],
                         :format     => docdiff.config[:format],
                         :digest     => docdiff.config[:digest]})
  print output

end # end if $0 == __FILE__
