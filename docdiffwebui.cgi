#!/usr/bin/ruby
# DocDiff Web UI (CGI)
# 2005-10-08.. Hisashi Morita
# requirement: Ruby 1.8+ (for timeout.rb)

require 'cgi'
require 'tempfile'
require 'open3'
require 'timeout'

docdiff="/usr/bin/docdiff"

cgi = CGI.new("html4")
file1 = Tempfile.new("file1-")
file1.print(cgi.params['file1'][0].read)
file1.close
file2 = Tempfile.new("file2-")
file2.print(cgi.params['file2'][0].read)
file2.close

if resolution = cgi.params['resolution'][0]
  case resolution.read
  when "line" then resolution = "line"
  when "word" then resolution = "word"
  when "char" then resolution = "char"
  else raise "Consult your system administrator.  Unsupported resolution."
  end
else
  raise "resolution unavailable."
end

if format = cgi.params['format'][0]
  case format.read
  when "html"   then format = "html"
  when "tty"    then format = "tty"
  when "wdiff"  then format = "wdiff"
  when "manued" then format = "manued"
  else raise "Consult your system administrator.  Unsupported format."
  end
else
  raise "format unavailable."
end

if encoding = cgi.params['encoding'][0]
  case encoding.read
  when "auto"  then encoding = "auto"
  when "ascii" then encoding = "ASCII"
  when "utf8"  then encoding = "UTF-8"
  when "eucjp" then encoding = "EUC-JP"
  when "sjis"  then encoding = "Shift_JIS"
  else raise "Consult your system administrator.  Unsupported encoding."
  end
else
  raise "encoding unavailable."
end

if eol = cgi.params['eol'][0]
  case eol.read
  when "auto" then eol = "auto"  
  when "cr"   then eol = "CR"
  when "lf"   then eol = "LF"
  when "crlf" then eol = "CRLF"
  else raise "Consult your system administrator.  Unsupported eol."
  end
else
  raise "eol unavailable."
end

digest = cgi.params['digest'][0]
if digest && digest.read == "digest"
  digest = "--digest"
else
  digest = ""
end

begin
  cmderr = ""
  cgierr = ""
  output = ""
  cmdline = "#{docdiff} " +
            " --resolution=#{resolution} --format=#{format} " +
            " --encoding=#{encoding} --eol=#{eol} #{digest} " +
            " #{file1.path} #{file2.path} "
  raise "file1 is empty." if FileTest.zero?(file1.path)
  raise "file2 is empty." if FileTest.zero?(file2.path)
  raise "file1 is unreadable." unless FileTest.readable?(file1.path)
  raise "file2 is unreadable." unless FileTest.readable?(file2.path)
  timeout(30){
    output = IO.popen(cmdline, "rb").read
    raise "stdout is nil." if output == nil
    raise "stdout is empty." if output == ""
  }
rescue Timeout::Error => cgierr
  output = "Consult your system administrator.<br />" +
           "CGI error: #{CGI.escapeHTML(cgierr.inspect)}<br />" +
           "Command error: #{CGI.escapeHTML(cmderr.inspect)}<br />" +
           "Commandline: #{CGI.escapeHTML(cmdline.inspect)}<br />" +
           "file1: #{CGI.escapeHTML(file1.inspect)}<br />" +
           "file1: #{CGI.escapeHTML(File.stat(file1.path).inspect)}<br />" +
           "file2: #{CGI.escapeHTML(file2.inspect)}<br />" +
           "file2: #{CGI.escapeHTML(File.stat(file2.path).inspect)}<br />"
  begin # popen failed, so falling back to open3, though open3 can fail too...
    timeout(30){
      stdin, stdout, stderr = Open3.popen3(cmdline)
      raise "stdin is nil." unless stdin
      raise "stdout is nil." unless stdout
      raise "stderr is nil." unless stderr
      cmderr = stderr.read
      raise cmderr if cmderr && cmderr.length > 0
      output = stdout.read
      raise "stdout is nil." if output == nil
      raise "stdout is empty." if output == ""
    }
  rescue Timout::Error => cgierr
    output = "Consult your system administrator.<br />" +
             "CGI error: #{CGI.escapeHTML(cgierr.inspect)}<br />" +
             "Command error: #{CGI.escapeHTML(cmderr.inspect)}<br />" +
             "Commandline: #{CGI.escapeHTML(cmdline.inspect)}<br />" +
             "file1: #{CGI.escapeHTML(file1.inspect)}<br />" +
             "file1: #{CGI.escapeHTML(File.stat(file1.path).inspect)}<br />" +
             "file2: #{CGI.escapeHTML(file2.inspect)}<br />" +
             "file2: #{CGI.escapeHTML(File.stat(file2.path).inspect)}<br />"
  end
rescue => cgierr
  output = "Consult your system administrator.<br />" +
           "CGI error: #{CGI.escapeHTML(cgierr.inspect)}<br />" +
           "Command error: #{CGI.escapeHTML(cmderr.inspect)}<br />" +
           "Commandline: #{CGI.escapeHTML(cmdline.inspect)}<br />" +
           "file1: #{CGI.escapeHTML(file1.inspect)}<br />" +
           "file1: #{CGI.escapeHTML(File.stat(file1.path).inspect)}<br />" +
           "file2: #{CGI.escapeHTML(file2.inspect)}<br />" +
           "file2: #{CGI.escapeHTML(File.stat(file2.path).inspect)}<br />"
ensure
  cgi.out {
    if output
      output
    else
      "Consult your system administrator.  Output was nil."
    end
  }
end
