require "docdiff/diff"
require "pp"

#a = "Hi, I am matz.  I am Ruby's father.".split
#b = "Hello, I am eban.  I am just another Ruby porter.".split

a = [:a, :b, :c, :d, :e, :f, :g, :h, :i, :j]
b = a.reverse
b = [:a, :b, :x, :y, :e, :f, :g, :h, :i, :j]

diff = Diff.new(a, b)
#pp a
#pp b
#pp diff.lcs(:speculative)
#diff.ses(:speculative)
diff.ses(:contours)
#diff.ses(:shortestpath)

=begin
pp diff.lcs(:shortestpath)
pp diff.ses(:shortestpath)

pp diff.lcs(:shortestpath)
pp diff.ses(:shortestpath)
=end

=begin
a = "Hi, I am matz.  I am Ruby's father.".split(//)
b = "Hello, I am eban.  I am just another Ruby porter.".split(//)
diff = Diff.new(a, b)
pp a
pp b
pp diff.lcs(:speculative)
pp diff.ses(:speculative)
=end
