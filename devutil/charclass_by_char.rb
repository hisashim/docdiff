#!/usr/bin/ruby
# test character classes on ASCII characters.
# 2003-03-10 Hisashi MORITA

charclasses = ["[:cntrl:]", 
               "[:space:]", "[:blank:]", 
               "[:digit:]", 
               "[:alpha:]", "[:alnum:]", 
               "[:punct:]",
               "[:lower:]", "[:upper:]",  
               "[:print:]", "[:graph:]", 
               "[:xdigit:]"]
(0x00 .. 0xff).to_a.each{|char|
  attribute = []
  charclasses.each{|charclass|
    if Regexp.new("[#{charclass}]") =~ char.to_a.pack("C*")
      attribute.push charclass
    end
  }
  puts "#{sprintf("\\x%02x", char)} (#{char.to_a.pack('C*').inspect})\t#{attribute.join(', ')}"
}
