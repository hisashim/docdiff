#!/usr/bin/ruby
# DocDiff 0.3
# 2002-06-27 Thu ... 2003-03-25 Mon ...
# Hisashi MORITA
# These scripts are distributed under the same license as Ruby's.
# requirement: Ruby (> 1.6), diff library by akr (included in Ruby/CVS),
#              Uconv by Yoshidam, NKF (for unit-testing)

require 'difference'
require 'charstring'
require 'diff'

class DocDiff

  APP_VERSION = '0.3.0'
  COPYRIGHT = 'Copyleft 2002-2003 Hisashi MORITA'
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

end  # class DocDiff

if $0 == __FILE__
  docdif = DocDiff.new
end
