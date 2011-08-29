#!/usr/bin/env ruby
require 'pp'
require 'optparse'

require_relative('ptj_libpath')
require 'ptj/default_setup'

DataMapper::Model.raise_on_save_failure = true if $DEBUG

include PTJ

FILTER = {:fields => [:password, :id]}

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

  o.on("-o", "--output FILENAME", String, "Where to output results (Default outputs to screen)") do |f|
    CFG[:file] = f
  end

  o.on("--max-size SIZE", Integer, "Maximum size of the resulting passords") do |f|
    FILTER[:size.lt] = f
  end

  o.on("--min-size SIZE", Integer, "Minimum size of the resulting passwords") do |f|
    FILTER[:size.gt] = f
  end

  o.on("--max-results SIZE", Integer, "Maximum number of results to return") do |f|
    CFG[:max_results] = f
  end
  
  o.on("--include-count", "Include the counts of passwords identified") do |f|
    CFG[:includecount] = f
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

time_now = Time.now

#raise(OptionParser::MissingArgument, "Must specify file with -f or password with -p") if (CFG[:file].nil? and CFG[:password].nil?)
def top_pass(object, my_hash)
  my_hash.delete(:fields) if my_hash[:fields]
  my_hash.delete(:order) if my_hash[:order]
  return object.aggregate(:password, :password.count, my_hash).sort {|x,y| y[1] <=> x[1]}
end

if CFG[:tags]
  if CFG[:max_results]
    o_pass = top_pass(PTJ::Tag.all(:tag => CFG[:tags]).passwords, FILTER).first(CFG[:max_results])
  else
    o_pass = top_pass(PTJ::Tag.all(:tag => CFG[:tags]).passwords, FILTER)
  end
else
  if CFG[:max_results]
    o_pass = top_pass(PTJ::Passwords.all, FILTER).first(CFG[:max_results])
  else
    o_pass = top_pass(PTJ::Passwords.all, FILTER)
  end
end


if CFG[:file]
  File.open(CFG[:file], "w+") do |file_handle|
    o_pass.each do |tiny_array|
      if CFG[:includecount] 
        file_handle.puts "#{tiny_array[0]}, #{tiny_array[1]}" 
      else
        file_handle.puts "#{tiny_array[0]}"
      end
    end
  end
else
  o_pass.each do |tiny_array|
    if CFG[:includecount]
      puts "#{tiny_array[0]}, #{tiny_array[1]}"
    else
      puts "#{tiny_array[0]}"
    end
  end
end
puts "Time Taken: #{Time.now - time_now}"
exit


