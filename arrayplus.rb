#!/usr/bin/ruby
# ArrayPlus

module ArrayPlus

  def freq(arg = nil)
    counter = {}
    if arg
      each{|e|
        if e == arg
          counter[e] || counter[e] = 0
          counter[e] += 1
        end
      }
      return counter[arg]
    elsif block_given?
      each{|e|
        if yield e
          counter[e] || counter[e] = 0
          counter[e] += 1
        end
      }
      return counter
    else
      # No arg or block given.
      each{|e|
        counter[e] || counter[e] = 0
        counter[e] += 1
      }
      return counter
    end
    raise "You are not supposed to see this.\n"
  end

  def count(arg = nil)
    if arg
      return freq(arg)
    elsif block_given?
      return freq{|a| yield a}.size
    else
      return size  # raise "Gimme arg or block.\n"
    end
    raise "You are not supposed to see this.\n"
  end

  def pick_indice(arg = nil)
    indice = []
    if arg
      each_with_index{|e, i|
        indice.push i if e == arg
      }
      return indice
    elsif block_given?
      each_with_index{|e, i|
        indice.push i if yield e
      }
      return indice
    else
      each_with_index{|e, i|
        indice.push i
      }
      return indice
    end
    raise "You are not supposed to see this.\n"
  end
  alias :pick_indexes :pick_indice

end

if $0 == __FILE__

  class Array
    include ArrayPlus
  end

  if seed = ARGV.shift
    srand seed.to_i
  else
    raise "Give me a seed for randomization.\n"
  end

  if num = ARGV.shift
    n = num.to_i
  else
    n = 10
  end

  a = (1..n).to_a.collect{
    (n * (rand - 0.5)).to_i
  }

  puts "a:                   \t#{a.inspect}"
  puts "a.freq:              \t#{a.freq.inspect}"
  puts "a.freq(3):           \t#{a.freq(3).inspect}"
  puts "a.freq{|e|e<3}:      \t#{a.freq{|e| e < 3}.inspect}"
  puts "a.count(3)           \t#{a.count(3).inspect}"
  puts "a.count{|e|e<3}      \t#{a.count{|e| e < 3}.inspect}"
  puts "a.pick_indice(3)     \t#{a.pick_indice(3).inspect}"
  puts "a.pick_indice{|e|e<3}\t#{a.pick_indice{|e| e < 3}.inspect}"

end
