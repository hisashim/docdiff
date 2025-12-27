require 'optparse'

class DocDiff
  module CLI
    class << self
      def parse_options!(args, base_options: {})
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
            encoding_aliases = {
              "ascii" => "ASCII",
              "euc-jp" => "EUC-JP",
              "shift_jis" => "Shift_JIS",
              "cp932" => "CP932",
              "utf-8" => "UTF-8",
            },
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
            eol_aliases = { "cr" => "CR", "lf" => "LF", "crlf" => "CRLF" },
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

      def parse_config_file_content(content)
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

      def read_config_from_file(filename)
        content = nil
        begin
          File.open(filename, "r"){|f| content = f.read}
        rescue => exception
          raise exception
        ensure
          message =
            case exception
            in Errno::ENOENT
              "config file not found: #{filename.inspect}"
            in Errno::EACCES
              "permission denied for reading: #{filename.inspect}"
            else
              "something unexpected happened: #{filename.inspect}"
            end
          if content
            config = parse_config_file_content(content)
          else
            message = "config file empty: #{filename.inspect}"
          end
        end
        [config, message]
      end

      def print_or_write_to_pager(content, pager)
        if STDOUT.tty? && pager.is_a?(String) && !pager.empty?
          IO.popen(pager, "w"){|f| f.print content}
        else
          print content
        end
      end

      def run
        command_line_config = parse_options!(ARGV)

        system_config =
          unless command_line_config[:no_config_file]
            possible_system_config_file_names = [
              DocDiff::SystemConfigFileName,
            ]
            existing_system_config_file_names =
              possible_system_config_file_names.select{|fn| File.exist? fn}
            if existing_system_config_file_names.size >= 2
              raise <<~EOS
              More than one system config file found, using the first one: \
              #{existing_system_config_file_names.inspect}
            EOS
            end
            filename = existing_system_config_file_names.first
            config, message = read_config_from_file(filename)
            STDERR.print message if command_line_config[:verbose]
            config
          end

        user_config =
          unless command_line_config[:no_config_file]
            possible_user_config_file_names = [
              DocDiff::UserConfigFileName,
              DocDiff::AltUserConfigFileName,
              DocDiff::XDGUserConfigFileName,
            ]
            existing_user_config_file_names =
              possible_user_config_file_names.select{|fn| File.exist? fn}
            if existing_user_config_file_names.size >= 2
              raise <<~EOS
              Only one user config file can be used at the same time. \
              Keep one and remove or rename the others: \
              #{existing_user_config_file_names.inspect}
            EOS
            end
            filename = existing_user_config_file_names.first
            config, message = read_config_from_file(filename)
            STDERR.print message if command_line_config[:verbose]
            config
          end

        config_from_specified_file =
          if filename = command_line_config[:config_file]
            config, message = read_config_from_file(filename)
            STDERR.print message if command_line_config[:verbose] == true
            config
          end

        config_from_program_name =
          case File.basename($PROGRAM_NAME, ".*")
          when "worddiff" then {:resolution => "word"}
          when "chardiff" then {:resolution => "char"}
          end

        config_from_env_vars = {}
        if (pager = ENV['DOCDIFF_PAGER']) && !pager.empty?
          config_from_env_vars[:pager] = pager
        end

        config_in_effect = DocDiff::DEFAULT_CONFIG.dup
        config_in_effect.merge!(config_from_program_name) if config_from_program_name
        config_in_effect.merge!(system_config) if system_config
        config_in_effect.merge!(user_config) if user_config
        config_in_effect.merge!(config_from_env_vars) if config_from_env_vars
        config_in_effect.merge!(config_from_specified_file) if config_from_specified_file
        config_in_effect.merge!(command_line_config) if command_line_config

        docdiff = DocDiff.new(config: config_in_effect)

        file1_content = nil
        file2_content = nil
        raise "Try `#{File.basename($0)} --help' for more information." if ARGV[0].nil?
        raise "Specify at least 2 target files." unless ARGV[0] && ARGV[1]
        ARGV[0] = "/dev/stdin" if ARGV[0] == "-"
        ARGV[1] = "/dev/stdin" if ARGV[1] == "-"
        raise "No such file: #{ARGV[0]}." unless FileTest.exist?(ARGV[0])
        raise "No such file: #{ARGV[1]}." unless FileTest.exist?(ARGV[1])
        raise "#{ARGV[0]} is not readable." unless FileTest.readable?(ARGV[0])
        raise "#{ARGV[1]} is not readable." unless FileTest.readable?(ARGV[1])
        File.open(ARGV[0], "r"){|f| file1_content = f.read}
        File.open(ARGV[1], "r"){|f| file2_content = f.read}

        doc1 = nil
        doc2 = nil

        encoding1 = docdiff.config[:encoding]
        encoding2 = docdiff.config[:encoding]
        eol1 = docdiff.config[:eol]
        eol2 = docdiff.config[:eol]

        if docdiff.config[:encoding] == "auto"
          encoding1 = DocDiff::CharString.guess_encoding(file1_content)
          encoding2 = DocDiff::CharString.guess_encoding(file2_content)
          case
          when (encoding1 == "UNKNOWN" or encoding2 == "UNKNOWN")
            raise "Document encoding unknown (#{encoding1}, #{encoding2})."
          when encoding1 != encoding2
            raise "Document encoding mismatch (#{encoding1}, #{encoding2})."
          end
        end

        if docdiff.config[:eol] == "auto"
          eol1 = DocDiff::CharString.guess_eol(file1_content)
          eol2 = DocDiff::CharString.guess_eol(file2_content)
          case
          when (eol1.nil? or eol2.nil?)
            raise "Document eol is nil (#{eol1.inspect}, #{eol2.inspect}).  The document might be empty."
          when (eol1 == 'UNKNOWN' or eol2 == 'UNKNOWN')
            raise "Document eol unknown (#{eol1.inspect}, #{eol2.inspect})."
          when (eol1 != eol2)
            raise "Document eol mismatch (#{eol1}, #{eol2})."
          end
        end

        doc1 = DocDiff::Document.new(file1_content, encoding1, eol1)
        doc2 = DocDiff::Document.new(file2_content, encoding2, eol2)

        output = docdiff.run(doc1, doc2,
                             {:resolution => docdiff.config[:resolution],
                              :format     => docdiff.config[:format],
                              :digest     => docdiff.config[:digest],
                              :display    => docdiff.config[:display]})

        print_or_write_to_pager(output, docdiff.config[:pager])
      end
    end
  end
end
