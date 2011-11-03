#!/usr/bin/env ruby
require 'pp'
require 'optparse'
require 'progressbar'

require_relative('ptj_libpath')
require 'ptj/default_setup'

DataMapper::Model.raise_on_save_failure = true if $DEBUG

include PTJ

FILTER = {}

CFG = {
  :password => nil,
  :pw_hash => "",
  :tags => [],
  :basename => true,
  :file => nil
}

opts = OptionParser.new do |o|
  o.banner = "Usage: #{File.basename $0} [opts] -f file|-p password"

  o.on_tail("-h", "--help", "Show this message.") do
    puts o
    exit 1
  end

  o.on("-t", "--tag TAGS", "Tags to be used to identify imported passwords (separated by a comma)") do |t|
    t = t.split(",").each{|x| x.strip!}
    t=[t] unless t.is_a?(Array)
    t.each do |tag|
      mytag=(Tag.get(tag) || Tag.create(:tag => tag.to_s))
      CFG[:tags] << mytag
    end
  end

  o.on("--[no-]strict", "Enable/Disable Strict Mode") do |s|
    DataMapper::Model.raise_on_save_failure = s
  end

  o.on("-f", "--file FILENAME", String, "File to import.") do |f|
    CFG[:file] = f
  end

  o.on("-r", "--parser NUMBER", Integer, "File parser to use:", "1 - Password Only", "2 - Hash:Password", "3 - Count, Password", "4 - Something ::: Password ::: Something") do |f|
    case f
    when 1
      CFG[:parser] = Parser::PassOnly.new
    when 2
      CFG[:parser] = Parser::HashPassOnlyColon.new
    when 3
      CFG[:parser] = Parser::CountPassOnly.new
    when 4
      CFG[:parser] = Parser::PassThreeColons.new
    else
      raise(OptionParser::InvalidOption, "Incorrect parsing number specified.")
    end
  end

  o.on("-p", "--password PASSWORD", String, "Password to import.") do |f|
    CFG[:file] = f
  end

  o.on("-a", "--hash HASH", String, "Hash to import (Use in conjunction with -p).") do |f|
    CFG[:file] = f
  end

end.parse!(ARGV)

raise(OptionParser::MissingArgument, "Must specify file with -f or password with -p") if (CFG[:file].nil? and CFG[:password].nil?)

def import_file
  file = Pathname.new(CFG[:file])
  parser = CFG[:parser]
  tags = CFG[:tags]
  file_obj = File.new(file, "r")
  total_count = parser.total_count(file)
  prog = ProgressBar.new("Importing...", total_count+1)
  counter = 0
  threshold = 2000
  queue_array = []
  while (line = file_obj.gets)
    begin
      line = line.force_encoding("BINARY")
      parsed = parser.parse_line(line)
      queue_array = queue_array + parsed
      while (queue_array.size > threshold)
        Password.transaction do
          queue_array[0..(threshold-1)].each do |myhash|
            next if myhash[:mypass].to_s.empty?
            pass = Password.create(:password => myhash[:mypass], :pw_hash => myhash[:myhash]||"")
            prog.set(counter)
            counter = counter+1
            pass.save
            tags.each{|tag| pass.tags << tag}
            pass.save
          end
          queue_array = queue_array[(threshold)..queue_array.size]
        end
      end
    rescue StandardError => e
      p e.message
      next
    end
  end

  begin
    Password.transaction do
      queue_array.each do |myhash|
        next if myhash[:mypass].to_s.empty?
        pass = Password.create(:password => myhash[:mypass], :pw_hash => myhash[:myhash]||"")
        prog.set(counter)
        counter = counter+1
        pass.save
        tags.each{|tag| pass.tags << tag}
        pass.save
      end
    end
  rescue StandardError => e
    p e.message
  end
end

import_file

