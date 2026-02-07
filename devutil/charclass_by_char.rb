#!/usr/bin/env ruby
# frozen_string_literal: true

# List ASCII characters with matching character classes
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
  chars.map do |char|
    char_packed = [char].pack("C*")
    attribute =
      charclasses.reduce([]) do |acc, charclass|
        if /[#{charclass}]/.match(char_packed)
          acc << charclass
        else
          acc
        end
      end
    hex = format("\\x%02x", char)
    packed_string = [char].pack("C*").inspect
    attributes = attribute.join(", ")

    "#{hex} (#{packed_string})\t#{attributes}"
  end

puts result
