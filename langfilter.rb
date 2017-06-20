#!/usr/bin/ruby
# language filter
# usage: langfilter.rb --en <infile >outfile

lang_to_include = ARGV.shift.gsub(/-+/, "")
lang_to_exclude = {"en"=>"ja", "ja"=>"en"}[lang_to_include]
re = /<([a-z]+) +(?:(?:lang|title)="#{lang_to_exclude}").*?>.*?<\/\1>[\r\n]?/m

ARGF.set_encoding("UTF-8")
ARGF.read.gsub(re, "").display
