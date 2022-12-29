#!/usr/bin/env ruby
require 'json'

DAYS = 25

def load_solutions
  @solutions = JSON.parse(File.read("solutions"))
  @match_solutions = true
rescue StandardError => e
  puts e.message
  @match_solutions = false
end

total_time = 0

if ARGV[0]
  day = ARGV[0].to_i
  range = (day..day)
else
  range = (1..DAYS)
end

load_solutions

puts "Day   Time"
puts "----------------"

range.each do |n|
  require_relative "day#{n.to_s.rjust(2, '0')}.rb"

  day_class = Kernel.const_get("Day#{n}")
  t1 = Time.now
  day = day_class.new
  res1 = day.one
  res2 = day.two
  t2 = Time.now
  time = 1000.0 * (t2 - t1)
  total_time += time
  
  if @match_solutions
    raise "Failed day #{n} part 1. Expected #{@solutions[n-1][0]} got #{res1}" if @solutions[n-1][0] != res1
    raise "Failed day #{n} part 2. Expected #{@solutions[n-1][1]} got #{res2}" if @solutions[n-1][1] != res2
  end

  if time < 100.0
    color_code = 32
  elsif time < 1000.0
    color_code = 33
  else
    color_code = 31
  end
  puts sprintf("%2s    \e[#{color_code}m#{time.round(2)} ms\e[0m", n)
end

puts "----------------"
puts "      #{total_time.round(2)} ms"