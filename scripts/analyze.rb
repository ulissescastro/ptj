#!/usr/bin/env ruby
require 'pp'
require 'optparse'

require_relative('ptj_libpath')
require 'ptj/default_setup'

DataMapper::Model.raise_on_save_failure = true if $DEBUG

include PTJ

FILTER = {}
CFG = {
  :tags => [],
  :file => nil,
  :includecount => false
}

opts = OptionParser.new do |o|
  o.banner = "Usage: #{File.basename $0} [opts]"

  o.on_tail("-h", "--help", "Show this message") do
    puts o
    exit 1
  end

  o.on("-t", "--tags TAGS", "Tags to be used to when querying passwords (separated by a comma)") do |t|
    t = t.split(",").each{|x| x.strip!}
    t=[t] unless t.is_a?(Array)
    t.each do |tag|
      CFG[:tags] << tag
    end
  end

  o.on("--max-size SIZE", Integer, "Maximum size of the resulting passords") do |f|
    FILTER[:size.lte] = f
  end

  o.on("--min-size SIZE", Integer, "Minimum size of the resulting passwords") do |f|
    FILTER[:size.gte] = f
  end

  o.on("--[no-]upper", "Query based on upper-case letters") do |f|
    FILTER[:upper] = f
  end

  o.on("--[no-]lower", "Query based on lower-case letters") do |f|
    FILTER[:lower] = f
  end

  o.on("--[no-]special", "Query based on special charaters") do |f|
    FILTER[:special] = f
  end

  o.on("--[no-]number", "Query based on numbers") do |f|
    FILTER[:number] = f
  end

end.parse!(ARGV)

def top5_pass(object, my_hash)
  my_hash.delete(:fields) if my_hash[:fields]
  my_hash.delete(:order) if my_hash[:order]
  return object.aggregate(:password, :password.count, my_hash).sort {|x,y| y[1] <=> x[1]}.first(5)
end

def size_count(object, my_hash)
  my_hash.delete(:fields) if my_hash[:fields]
  my_hash.delete(:order) if my_hash[:order]
  return object.aggregate(:size, :size.count, my_hash).sort {|x,y| x[0] <=> y[0]}
end

def top_sequences(object, my_hash)
  my_hash.delete(:fields) if my_hash[:fields]
  my_hash.delete(:order) if my_hash[:order]
  return object.aggregate(:sequence, :sequence.count, my_hash).sort {|x,y| y[1] <=> x[1]}.first(5)
end

def cat_result(object, my_hash)
  my_hash.delete(:fields) if my_hash[:fields]
  my_hash.delete(:order) if my_hash[:order]
  return_hash = {}
  return_hash["Lower"] = object.all(my_hash).count(:upper => false, :special => false, :lower => true, :number => false)
  return_hash["Upper"] = object.all(my_hash).count(:upper => true, :special => false, :lower => false, :number => false)
  return_hash["Number"] = object.all(my_hash).count(:upper => false, :special => false, :lower => false, :number => true)
  return_hash["Special"] = object.all(my_hash).count(:upper => false, :special => true, :lower => false, :number => false)
  return_hash["Lower/Upper"] = object.all(my_hash).count(:upper => true, :special => false, :lower => true, :number => false)
  return_hash["Lower/Number"] = object.all(my_hash).count(:upper => false, :special => false, :lower => true, :number => true)
  return_hash["Upper/Number"] = object.all(my_hash).count(:upper => true, :special => false, :lower => false, :number => true)
  return_hash["Lower/Special"] = object.all(my_hash).count(:upper => false, :special => true, :lower => true, :number => false)
  return_hash["Upper/Special"] = object.all(my_hash).count(:upper => true, :special => true, :lower => false, :number => false)
  return_hash["Number/Special"] = object.all(my_hash).count(:upper => false, :special => true, :lower => false, :number =>true)
  return_hash["Lower/Upper/Number"] = object.all(my_hash).count(:upper => true, :special => false, :lower => true, :number => true)
  return_hash["Lower/Upper/Special"] = object.all(my_hash).count(:upper => true, :special => true, :lower => true, :number => false)
  return_hash["Lower/Number/Special"] = object.all(my_hash).count(:upper => false, :special => true, :lower => true, :number => true)
  return_hash["Upper/Number/Special"] = object.all(my_hash).count(:upper => true, :special => true, :lower => false, :number =>true)
  return_hash["Lower/Upper/Number/Special"] = object.all(my_hash).count(:upper => true, :special => true, :lower => true, :number => true)
  return_hash
end



time_now = Time.now
if CFG[:tags].empty?
  top5 = top5_pass(PTJ::Password.all, FILTER)
  top_seq = top_sequences(PTJ::Password.all, FILTER)
  my_count = size_count(PTJ::Password.all, FILTER)
  split_up = cat_result(PTJ::Password.all, FILTER)
else
  top5 = top5_pass(PTJ::Tag.all(:tag => CFG[:tags]).passwords, FILTER)
  top_seq = top_sequences(PTJ::Tag.all(:tag => CFG[:tags]).passwords, FILTER)
  my_count = size_count(PTJ::Tag.all(:tag => CFG[:tags]).passwords, FILTER)
  split_up = cat_result(PTJ::Tag.all(:tag => CFG[:tags]).passwords, FILTER)
end


puts "-=-=-=-=-=- Top 5 Passwords -=-=-=-=-=-"
top5.each do |pass, count|
  printf("%-30s : %d", pass, count)
  puts ""
end

total_size = 0

my_count.each{|result| total_size += result[1] }

puts "\n-=-=-=-=-=- Password Length -=-=-=-=-=-"
my_count.each do |result|
  percent = "%.2f" % ((result[1].to_f/total_size.to_f)*100).to_f  
  printf("%-30s %s", ("Password Length: #{result[0]}"), ("Count: #{result[1]} (#{percent}%)") )
  puts ""
end
puts "Total: #{total_size}"

puts "\n-=-=-=-=-=- Password Type -=-=-=-=-=-"
split_up.sort_by{|k,v| k.length}.each do |result|
  printf("Type: %-30s %s", result[0], ("Result: #{result[1]}"))
  puts ""
end

puts "\n-=-=-=-=-=- Top Sequences -=-=-=-=-=-"
top_seq.each do |seq, count|
  printf("%-30s : %d", seq, count)
  puts ""
end
puts "\nTime taken: #{Time.now - time_now}"
