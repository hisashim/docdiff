#!/usr/bin/ruby
# DocDiff Web UI (CGI)
# 2005-10-08.. Hisashi Morita
# requirement: Ruby 2.0+ (for timeout.rb)

require 'cgi'
require 'tempfile'
require 'open3'
require 'timeout'

docdiff = "/usr/bin/docdiff"

def errmsg(bndg) # receive binding and return error anatomy
  timeout_second = eval("timeout_second", bndg)
  meth    = eval("meth", bndg)
  cgierr  = eval("cgierr", bndg)
  cmderr  = eval("cmderr", bndg)
  cmdline = eval("cmdline", bndg)
  file1   = eval("file1", bndg)
  file2   = eval("file2", bndg)
  msg = ["<h1>I am so sorry, but something went wrong and an error occured.</h1>",
         "<h2>For users:</h2>",
         "<p>#{cgierr}</p>",
         "<p>#{'You may try again specifying encoding and eol explicitly.' if cmderr.size > 0}</p>",
         "<p>If you are still in trouble after self-help effort, please consult your system administrator (or nearest geek) with the detail below.</p>",
         "<hr />",
         "<h2>For system administrators:</h2>",
         "<p>Technical detail of the error:</p>",
         "<p>",
         "CGI error: #{CGI.escapeHTML(cgierr.inspect)}<br />",
         "Command error: #{CGI.escapeHTML(cmderr.inspect)}<br />",
         "Timeout: #{timeout_second}<br />",
         "Method used: #{meth}<br />",
         "Commandline used: #{CGI.escapeHTML(cmdline.inspect)}<br />",
         "file1: #{CGI.escapeHTML(file1.inspect)}<br />",
         "file1 stat: #{CGI.escapeHTML(File.stat(file1.path).inspect)}<br />",
         "file2: #{CGI.escapeHTML(file2.inspect)}<br />",
         "file2 stat: #{CGI.escapeHTML(File.stat(file2.path).inspect)}<br />",
#          "file1 content: #{`head #{file1.path}`}<br />",
#          "file2 content: #{`head #{file2.path}`}<br />",
#          "#{`#{cmdline}`}",
         "</p><hr />"].join
  return msg
end

class InvalidUsageError < StandardError
end
class TimeoutErrorPopen < TimeoutError
end
class TimeoutErrorPopen3 < TimeoutError
end

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
  raise "param 'resolution' was not available."
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
  raise "param 'format' was not available."
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
  raise "param 'encoding' was not available."
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
  raise "param 'eol' was not available."
end

digest = cgi.params['digest'][0]
if digest && digest.read == "digest"
  digest = "--digest"
else
  digest = ""
end

if timeout_second = cgi.params['timeout_second'][0]
  case timeout_second.read
  when "5"  then timeout_second = 5
  when "15" then timeout_second = 15
  when "30" then timeout_second = 30
  when "60" then timeout_second = 60
  else raise "Consult your system administrator.  Unsupported timeout period."
  end
else
  raise "param 'timeout_second' was not available."
end

begin
  cmderr = ""
  cgierr = ""
  output = ""
  cmdline = "#{docdiff} " +
            " --resolution=#{resolution} --format=#{format} " +
            " --encoding=#{encoding} --eol=#{eol} #{digest} " +
            " #{file1.path} #{file2.path} "
  raise InvalidUsageError, "file1 is either empty (size 0) or not specified." if FileTest.zero?(file1.path)
  raise InvalidUsageError, "file2 is either empty (size 0) or not specified." if FileTest.zero?(file2.path)
  raise "file1 is unreadable." unless FileTest.readable?(file1.path)
  raise "file2 is unreadable." unless FileTest.readable?(file2.path)
  meth = "IO.popen"
  timeout(timeout_second, TimeoutErrorPopen){
    output = IO.popen(cmdline, "rb").read
    raise "stdout from docdiff is nil." if output == nil
    raise "stdout from docdiff is not nil, but empty." if output == ""
  }
rescue InvalidUsageError => cgierr
  output = errmsg(binding())

rescue TimeoutErrorPopen => cgierr
  # popen failed, so falling back to open3, though open3 can fail too...
  meth = "Open3.popen3"

  timeout(timeout_second, TimeoutErrorPopen3){
    stdin, stdout, stderr = Open3.popen3(cmdline)
    raise "stdin to docdiff is nil." unless stdin
    raise "stdout from docdiff is nil." unless stdout
    raise "stderr from docdiff is nil." unless stderr
    cmderr = stderr.read
    raise cmderr if cmderr && cmderr.length > 0
    output = stdout.read
  }
rescue TimeoutErrorPopen3  => cgierr
  output = errmsg(binding())
rescue => cgierr
  output = errmsg(binding())
ensure
  cgi.out {
    if output == nil then
      errmsg(binding())
    elsif output.size == 0 then
      errmsg(binding())
    else
      output
    end
  }
end
