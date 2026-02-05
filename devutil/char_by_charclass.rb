#!/usr/bin/env ruby
# frozen_string_literal: true

# test character classes on ASCII characters.
# 2003-03-10 Hisashi MORITA

charclasses = [
  "[:cntrl:]",
  "[:space:]",
  "[:blank:]",
  "[:digit:]",
  "[:alpha:]",
  "[:alnum:]",
  "[:punct:]",
  "[:lower:]",
  "[:upper:]",
  "[:print:]",
  "[:graph:]",
  "[:xdigit:]",
]

chars = (0x00..0xff).to_a

result =
  charclasses.map do |charclass|
    charclass_re = /[#{charclass}]/
    member_chars =
      chars.reduce([]) do |acc, char|
        if charclass_re.match([char].pack("C*"))
          acc << char
        else
          acc
        end
      end
    member_chars_in_hex =
      member_chars.map { |char| format("\\x%02x", char) }.join
    member_chars_packed =
      member_chars.map { |char| [char].pack("C*").inspect[1..-2] }.join

    <<~EOS
      #{charclass}\t#{member_chars_in_hex}
      \t\t(#{member_chars_packed})
    EOS
  end

puts result
