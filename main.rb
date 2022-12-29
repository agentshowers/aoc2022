#!/usr/bin/env ruby
require 'json'
require 'optparse'

DAYS = 25

def download_inputs

end

def solve(range)
  range.map do |n|
    require_relative "day#{n.to_s.rjust(2, '0')}.rb"
  
    day_class = Kernel.const_get("Day#{n}")
    t1 = Time.now
    day = day_class.new
    res1 = day.one
    res2 = day.two
    t2 = Time.now
    time = 1000.0 * (t2 - t1)

    [n, res1, res2, time]
  end
end

def validate(solutions)
  expected = JSON.parse(File.read("solutions"))
  solutions.each do |n, pt1, pt2, _|
    raise "Failed day #{n} part 1. Expected #{expected[n-1][0]} got #{res1}" if expected[n-1][0] != pt1
    raise "Failed day #{n} part 2. Expected #{expected[n-1][1]} got #{res2}" if expected[n-1][1] != pt2
  end
rescue StandardError => e
  puts "Failed to load 'solutions' file: #{e.message}\nWill not validate expected output"
end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: main.rb [options]"

  opts.on("-d", "--dev", "Development mode") do |v|
    options[:dev] = v
  end

end.parse!

range = (1..DAYS)
if ARGV[0]
  day = ARGV[0].to_i
  range = (day..day)
end

download_inputs
solutions = solve(range)
validate(solutions) unless options[:dev]

total_time = solutions.map {_1[3]}.sum

puts "-----------------------------------------------------------------"
puts "| Day | Part 1               | Part 2               | Time       |"
puts "-----------------------------------------------------------------"


solutions.each do |day, pt1, pt2, time|
  if time < 100.0
    color_code = 32
  elsif time < 1000.0
    color_code = 33
  else
    color_code = 31
  end
  time_str = "#{time.round(2).to_s} ms"
  puts sprintf("| %-3s | %-20s | %-20s | \e[#{color_code}m%-10s\e[0m |", day, pt1, pt2, time_str)
end

puts "-----------------------------------------------------------------\n"
puts " "*42 + "Total time: #{total_time.round(2)} ms"
