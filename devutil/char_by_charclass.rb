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
chars = (0x00 .. 0xff).to_a

charclasses.each{|charclass|
  member_chars = []
  chars.each{|char|
    if Regexp.new("[#{charclass}]") =~ char.to_a.pack("C*")
      member_chars.push char
    end
  }
  puts "#{charclass}\t#{member_chars.collect{|char|sprintf("\\x%02x", char)}.join}\n\t\t(#{member_chars.collect{|char|char.to_a.pack('C*').inspect[1..-2]}.join})"
}
