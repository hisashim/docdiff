require 'optparse'

class DocDiff
  module CLI
    def self.parse_options!(args, base_options: {})
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
        ){|s| o[:label] ||= []; o[:label] << s}

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

    def self.parse_config_file_content(content)
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

    def self.read_config_from_file(filename)
      content = nil
      begin
        File.open(filename, "r"){|f| content = f.read}
      rescue Errno::ENOENT
        message = "config file not found, skipping: #{filename.inspect}"
      ensure
        if content
          config = parse_config_file_content(content)
        else
          message = "config file empty: #{filename.inspect}"
        end
      end
      [config, message]
    end
  end
end
