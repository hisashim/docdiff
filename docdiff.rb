#!/usr/bin/ruby
# DocDiff 0.3
# 2002-06-27 Thu ... 2003-03-25 Mon ...
# Hisashi MORITA
# These scripts are distributed under the same license as Ruby's.
# requirement: Ruby (> 1.6), diff library by akr (included in Ruby/CVS),
#              Uconv by Yoshidam, NKF

require 'difference'
require 'document'
require 'view'
require 'optparse'

class DocDiff

  AppVersion = '0.3.0'
  Author = "Copyright (C) 2002-2004 Hisashi MORITA.\n" +
           "diff library originates from Ruby/CVS by TANAKA Akira.\n"
  License = "This software is licensed under the same license as Ruby's."
  SystemConfigFileName = File.join(File::Separator, "etc", "docdiff", "docdiff.conf")
  UserConfigFileName = File.join(ENV['HOME'], "etc", "docdiff", "docdiff.conf")
  # USAGE

  # configuration
  # priority: default < ~/.docdiff < command line option
  #
  # command line options (draft)
  #
  # --version
  # --license
  # --help  -h
  # --debug
  ## --verbose
  #
  # --resolution=<unit>  --granularity
  #   <unit>: char | word | line
  #
  ## --cache= auto | on | off
  ## --cachedir= auto | <path>
  ## --conffile= auto | <path>
  #
  ### --input-type= text | html | xml
  ## --input-language= English | Japanese
  ## --input-encoding= auto | ASCII | EUC-JP | Shift_JIS | UTF-8
  ## --input-eol= auto | LF | CR | CRLF
  #
  ### --analysis= none | simple | complex
  #
  ## --detail= all | summary | digest
  ## --show-stat=off|on
  ## --show-document=on|off
  #
  ## --context=<integer><unit>,<integer><unit>
  ##   <unit>: char | word | line
  #
  ### --show-unified
  ### --show-source-only
  ### --show-target-only
  ### --show-common=on|off
  ### --show-removed=on|off
  ### --show-added=on|off
  #
  # --output-type= docdiff | tty | html | xhtml | manued
  ## --output-encoding= auto | ASCII | EUC-JP | Shift_JIS | UTF-8
  ## --output-eol= auto | original | system | LF | CR | CRLF
  #
  ## --tag-common="<>,</>"
  ## --tag-removed="<->,</->"  --tag-deleted
  ## --tag-added="<+>,</+>"    --tag-inserted

  def initialize()
    @config = {}
  end
  attr_accessor :config

#   def DocDiff.get_system_config_from_file()
#     filename = File.join(File::Separator,"etc","docdiff","docdiff.conf")
#     raise "File #{filename.inspect} does not exist." unless File.exist? filename
#     parse_conffile_content(File.read(filename, "r"))
#   end
#   def DocDiff.get_user_config_from_file()
#     filename = File.join(ENV['HOME'],"etc","docdiff","docdiff.conf")
#     raise "File #{filename.inspect} does not exist." unless File.exist? filename
#     parse_conffile_content(File.read(filename, "r"))
#   end
  def DocDiff.parse_config_file_content(content)
    raise "config file content is empty" if content.size <= 0
    lines = content.dup.split(/\r\n|\r|\n/).compact
    lines.collect!{|line| line.sub(/#.*$/, '')}
    lines.collect!{|line| line.strip}
    lines.delete_if{|line| line == ""}
    result = {}
    lines.each{|line|
      raise 'line does not include " = ".' unless /[\s]+=[\s]+/.match line
      pair = line.split(/[\s]+=[\s]+/)
      result[pair[0]] = pair[1]
    }
    result
  end

  def compare_by_line(doc1, doc2)
    Difference.new(doc1.split_to_line, doc2.split_to_line)
  end

  def compare_by_word(doc1, doc2)
    lines = compare_by_line(doc1, doc2)
    words = Difference.new
    lines.each{|line|
      if line.first == :change_elt
        before_change = Document.new(line[1].to_s, doc1.encoding, doc1.eol)
        after_change  = Document.new(line[2].to_s, doc2.encoding, doc2.eol)
        Difference.new(before_change.split_to_word, after_change.split_to_word).each{|word|
          words << word
        }
      else  # :common_elt_elt, :del_elt, or :add_elt
        words << line
      end
    }
    words
  end

  # i know this implementation of recursion is so lame...
  def compare_by_char(doc1, doc2)
    lines = compare_by_line(doc1, doc2)
    lines_and_words = Difference.new
    lines.each{|line|
      if line.first == :change_elt
        before_change = Document.new(line[1].to_s, doc1.encoding, doc1.eol)
        after_change  = Document.new(line[2].to_s, doc2.encoding, doc2.eol)
        Difference.new(before_change.split_to_word, after_change.split_to_word).each{|word|
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

  def run(doc1, doc2, resolution, viewtype, option = nil)
    raise unless (doc1.class == Document && doc2.class == Document)
    raise unless (doc1.encoding == doc2.encoding && doc1.eol == doc2.eol)
    case resolution
    when :line; then difference = compare_by_line(doc1, doc2)
    when :word; then difference = compare_by_word(doc1, doc2)
    when :char; then difference = compare_by_char(doc1, doc2)
    else raise "#{resolution.inspect} is not supported as resolution."
    end
    view = View.new(difference, doc1.encoding, doc1.eol)
    case viewtype
    when :terminal; then result = view.to_terminal(option)
    when :html;     then result = view.to_html(option)
    when :xhtml;    then result = view.to_xhtml(option)
    when :manued;   then result = view.to_manued(option)
    when :wdiff;    then result = view.to_wdiff(option)
    when :user_defined_markup; then result = view.user_defined_markup(option)
    else raise "#{view.inspect} is not supported as view."
    end
    result.to_s
  end

end  # class DocDiff

def process_config_file(filename)
  begin
    file_content = File.read(filename, "r")
  rescue Errno::ENOENT
    message = "config file not found so not read."
  ensure
    if file_content != nil
      docdiff.config.update(DocDiff.parse_config_file_content(file_content))
    end
  end
  message
end

if $0 == __FILE__

  # do_config_stuff

  default_config = {
    :resolution    => "word",
    :encoding      => "auto",
    :eol           => "auto",
    :format        => "manued",
    :cache         => true,
    :stat          => true,
    :digest        => false,
    :verbose       => false
  }

  clo = command_line_options = {}

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
                 possible_eols.join('|'), '(default is auto)'
                ){|clo[:eol]| clo[:eol] ||= "auto"}
    o.def_option('--cr', 'same as --eol=CR'){clo[:eol] = "CR"}
    o.def_option('--lf', 'same as --eol=LF'){clo[:eol] = "LF"}
    o.def_option('--crlf', 'same as --eol=CRLF'){clo[:eol] = "CRLF"}

    o.def_option('--format=FORMAT',
                 possible_formats = ['terminal','manued','html','xhtml','wdiff'],
                 'specify output format',
                 possible_formats.join('|'), '(default is manued)'
                ){|clo[:format]| clo[:format] ||= "manued"}
    o.def_option('--terminal', 'same as --format=terminal'){clo[:format] = "terminal"}
    o.def_option('--manued', 'same as --format=manued'){clo[:format] = "manued"}
    o.def_option('--html', 'same as --format=html'){clo[:format] = "html"}
    o.def_option('--xhtml', 'same as --format=xhtml'){clo[:format] = "html"}
    o.def_option('--wdiff', 'same as --format=wdiff'){clo[:format] = "wdiff"}

    o.def_option('--stat', 'show statistics'){clo[:stat] = true}
    o.def_option('--digest', 'digest output, do not show all'){clo[:digest] = true}
    o.def_option('--cache', 'use file cache'){clo[:cache] = true}
    o.def_option('--no-config-file',
                 'do not read config files'){clo[:no_config_file] = true}
    o.def_option('--verbose', 'run verbosely'){clo[:verbose] = true}

    o.def_option('--help', 'show this message'){puts o; exit(0)}
    o.def_option('--version', 'show version'){puts DocDiff::AppVersion; exit(0)}
    o.def_option('--license', 'show license'){puts DocDiff::License; exit(0)}
    o.def_option('--author', 'show author(s)'){puts DocDiff::Author; exit(0)}
    o.parse!
  } or exit(1)

  docdiff = DocDiff.new()
  docdiff.config.update(default_config)
  unless clo[:no_config_file] == true # process_commandline_option
    message = process_config_file(DocDiff::SystemConfigFileName)
    if clo[:verbose] == true || docdiff.config[:verbose] == true
      STDERR.print message
    end
    message = process_config_file(DocDiff::UserConfigFileName)
    if clo[:verbose] == true || docdiff.config[:verbose] == true
      STDERR.print message
    end
  end
  docdiff.config.update(clo)

  # config stuff done

  # process the documents

  file1_content = nil
  file2_content = nil
  File.open(ARGV[0], "r"){|f| file1_content = f.read}
  File.open(ARGV[1], "r"){|f| file2_content = f.read}

  doc1 = nil
  doc2 = nil
  if docdiff.config[:encoding] == "auto"
    encoding1 = CharString.guess_encoding(file1_content)
    encoding2 = CharString.guess_encoding(file2_content)
    case
    when (encoding1 == "UNKNOWN" or encoding2 == "UNKNOWN")
      raise "document encoding unknown."
    when encoding1 != encoding2
      raise "document encoding mismatch (#{encoding1}, #{encoding2})."
    end

    eol1 = CharString.guess_eol(file1_content)
    eol2 = CharString.guess_eol(file2_content)
    if eol1 != nil && (eol1 != eol2)
      raise "document eol mismatch (#{eol1}, #{eol2})."
    end
    doc1 = Document.new(file1_content, encoding1, eol1)
    doc2 = Document.new(file2_content, encoding2, eol2)
  else
    doc1 = Document.new(file1_content,
                        docdiff.config[:encoding],
                        docdiff.config[:eol])
    doc2 = Document.new(file2_content,
                        docdiff.config[:encoding],
                        docdiff.config[:eol])
  end

  case docdiff.config[:resolution]
  when "line"
    difference = docdiff.compare_by_line(doc1, doc2)
  when "word"
    difference = docdiff.compare_by_word(doc1, doc2)
  when "char"
    difference = docdiff.compare_by_char(doc1, doc2)
  else
    raise "no such resolution: #{docdiff.config[:resolution]}"
  end

  case docdiff.config[:format]
  when "terminal"
    view = View.new(difference, doc1.encoding, doc1.eol).to_terminal
  when "manued"
    view = View.new(difference, doc1.encoding, doc1.eol).to_manued
  when "html"
    view = View.new(difference, doc1.encoding, doc1.eol).to_html
  when "xhtml"
    view = View.new(difference, doc1.encoding, doc1.eol).to_xhtml
  when "wdiff"
    view = View.new(difference, doc1.encoding, doc1.eol).to_wdiff
  else
    raise "no such format: #{docdiff.config[:format]}"
  end

# require 'pp'
  print view

end # end if $0 == __FILE__
