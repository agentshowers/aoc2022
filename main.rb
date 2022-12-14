#!/usr/bin/env ruby

DAYS = 14

total_time = 0

(1..DAYS).each do |n|
  require_relative "day#{n.to_s.rjust(2, '0')}.rb"

  day_class = Kernel.const_get("Day#{n}")
  t1 = Time.now
  day = day_class.new
  res1 = day.one
  res2 = day.two
  t2 = Time.now
  time = 1000.0 * (t2 - t1)
  total_time += time

  puts "Day #{n} (#{time.round(2)} ms)"
  puts "1: #{res1}"
  puts "2: #{res2}"
  puts ""
end

puts "Total time: #{total_time.round(2)} ms"