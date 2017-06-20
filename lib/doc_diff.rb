# DocDiff: word/character-oriented text comparison utility
# Copyright (C) 2002-2011 Hisashi MORITA
# Requirements: Ruby (>= 2.0)
require 'docdiff/difference'
require 'docdiff/document'
require 'docdiff/view'

class DocDiff

  AppVersion = Docdiff::VERSION
  Author = "Copyright (C) 2002-2011 Hisashi MORITA.\n" +
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

end  # class DocDiff
