require 'dm-core'

module DataMapper

  class Collection < LazyArray

    def get_value(entry)
      returned_array = []
      self.each do |item|
        meth = item.method(entry)
        returned_array << meth.call()
      end
      returned_array
    end
  
    def analyze_and_sort
      b = Hash.new(0)
      self.each do |item|
        meth = item.method(entry)
        b[meth.call()] += 1
      end
      b = b.sort_by { |k,v| -1*v }
      b
    end

    def analyze
      h = Hash.new(0)
      self.each { | v | h.store(v, h[v]+1) }
      h
    end

    def sort_by_occurance(entry)
      returned_array = []
      sorted_array = self.analyze_and_sort(entry)
      sorted_array.each do |smaller_array|
        returned_array << smaller_array[0]
      end
      returned_array
    end

  end
end

class Array
  def analyze
    h = Hash.new(0)
    self.each { | v | h.store(v, h[v]+1) }
    h
  end

  def analyze_and_sort
    b = Hash.new(0)
    self.each { | v | b.store(v, b[v]+1) }
    b = b.sort_by { |k,v| -1*v }
    b
  end

  def analyze_and_sort_key
    b = Hash.new(0)
    self.each { | v | b.store(v, b[v]+1) }
    b = b.sort_by { |k,v| k }
    b
  end
end


module Kernel
  def Boolean(string)
    return true if string== true || string =~ (/(true|t|yes|y|1)$/i)
    return false if string== false || string.nil? || string =~ (/(false|f|no|n|0)$/i)
    raise ArgumentError.new("invalid value for Boolean: \"#{string}\"")
  end
end

