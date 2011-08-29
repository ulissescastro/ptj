#!/usr/bin/env ruby
require 'pp'
require 'optparse'

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

#o_pass_count = Password.all(:fields => [:id]).size


def import_file
  file = Pathname.new(CFG[:file])
  parser = CFG[:parser]
  tags = CFG[:tags]
  file = File.open(CFG[:file], "r")
  lines = file.readlines
  lines.each do |line|
    begin
      line = line.force_encoding("BINARY")
      parsed = parser.parse_line(line)
      mypass = parsed[:mypass]
      myhash = parsed[:myhash]
      next if mypass.to_s.empty?
      if parsed[:count]
        parsed[:count].to_i.times do 
          pass = Password.add_single(mypass, myhash)
          tags.each{|tag| pass.tags << tag}
          pass.save
          #puts "Adding #{mypass}"
        end
      else
        pass = Password.add_single(mypass, myhash)
        tags.each{|tag| pass.tags << tag}
        pass.save
        #puts "Adding #{mypass}"
      end
    rescue
      next
    end
  end
end

import_file


