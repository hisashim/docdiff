#!/usr/bin/ruby
# ArrayPlus
# 2002-9-x..  Hisashi MORITA

module ArrayPlus

  def freq(arg = nil)
    frequency = {}
    if arg
      each{|e|
        if e == arg
          frequency[e] || frequency[e] = 0
          frequency[e] += 1
        end
      }
      return frequency[arg]
    elsif block_given?
      each{|e|
        if yield e
          frequency[e] || frequency[e] = 0
          frequency[e] += 1
        end
      }
      return frequency
    else  # No arg or block given.
      each{|e|
        frequency[e] || frequency[e] = 0
        frequency[e] += 1
      }
      return frequency
    end
    raise "You are not supposed to see this.\n"
  end

  def count(arg = nil)
    if arg
      return self.freq(arg)
    elsif block_given?
      return self.freq{|a| yield a}.size
    else
      return self.size
    end
    raise "You are not supposed to see this.\n"
  end

  def locate(arg = nil)
    indices = []
    if arg
      each_with_index{|e, i| indices.push i if e == arg }
    elsif block_given?
      each_with_index{|e, i| indices.push i if yield e }
    else
      each_with_index{|e, i| indices.push i }  # all indices (=[0..n-1])
    end
    return indices
  end
  alias :pick_indexes :locate
  alias :pick_indices :locate

  ThisModule = self  # save module name
  # flatten given times
  def flatten(level = nil)
    if level == nil then next_level = nil
    elsif level > 0 then next_level = level - 1
    else                 return self
    end
    flattened = Array.new
    self.each{|elem|
      if elem.kind_of? Array
        elem.extend ThisModule  # inside a method, "self" is not a module but a class
        elem.flatten(next_level).each{|sub_elem|
          flattened << sub_elem
        }
      else
        flattened << elem
      end
    }
    return flattened
  end

  # [3,3,2,1,3].subtract([2,3]) #=> [3,1,3]
  def subtract(array_to_remove)
    rest = self.dup
    array_to_remove.each_with_index{|v, i|
      index_to_remove = rest.index(v)
      if index_to_remove
        rest.delete_at(index_to_remove)
      end
    }
    return rest
  end

  def longest()  # longest as String
    self.max{|a, b| [a.to_s.size, a.to_s] <=> [b.to_s.size, b.to_s]}
  end

  def shortest() # shortest as String
    self.min{|a, b| [a.to_s.size, a.to_s] <=> [b.to_s.size, b.to_s]}
  end

  def largest()  # largest as value (=max)
    self.sort{|a, b| a <=> b}.last
  end

  def smallest() # smallest as value (=min)
    self.sort{|a, b| a <=> b}.first
  end

  # median (Size/2-th)
  # [1,4,9,100,0].median    #=> 4
  # [1,4,9,50,100,0].median #=> (9+50)/2 => 29.5
  # [1,9,100,0].median      #=> (9+100)/2 => 54.5 
  def median()
    size = self.size
    if size % 2 == 1
      return self.sort[(size-1)/2]
    else
      result = (self[(size-2)/2] + self[size/2]) / 2.0
      return result.to_i if result == result.to_i
      return result
    end
  end

  # mode (most frequent)
  # [1,3,3,3,2,2,0].mode #=> 3
  # [1,3,3,2,2,0].mode # 2 or 3
  def mode()
    freq_table = self.sort{|a, b|
      self.count(a) <=> self.count(b)
    }
    if 2 <= freq_table.uniq.size
      mode1 = freq_table.uniq[-1]
      mode2 = freq_table.uniq[-2]
      # I don't know the precise definition of mode.
      #if self.count(mode1) == self.count(mode2)
      #  return [mode1, mode2]
      #else
        return mode1  # return smaller for now...
      #end
    else
      return freq_table.last
    end
  end

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

  puts "a:                    \t#{a.inspect}"
  puts "a.freq:               \t#{a.freq.inspect}"
  puts "a.freq(3):            \t#{a.freq(3).inspect}"
  puts "a.freq{|e|e<3}:       \t#{a.freq{|e| e < 3}.inspect}"
  puts "a.count(3)            \t#{a.count(3).inspect}"
  puts "a.count{|e|e<3}       \t#{a.count{|e| e < 3}.inspect}"
  puts "a.pick_indices(3)     \t#{a.pick_indices(3).inspect}"
  puts "a.pick_indices{|e|e<3}\t#{a.pick_indices{|e| e < 3}.inspect}"

end
