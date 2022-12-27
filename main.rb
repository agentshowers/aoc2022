#!/usr/bin/env ruby

SOLUTIONS = [
  [69883, 207576],
  [8392, 10116],
  [8018, 2518],
  [651, 956],
  ["VGBBJCRMN", "LBBVJBRMH"],
  [1779, 2635],
  [1449447, 8679207],
  [1715, 374400],
  [6023, 2533],
  [13760, "\n###  #### #  # ####  ##  ###  #### #### \n#  # #    # #     # #  # #  # #    #    \n#  # ###  ##     #  #    #  # ###  ###  \n###  #    # #   #   #    ###  #    #    \n# #  #    # #  #    #  # #    #    #    \n#  # #    #  # ####  ##  #    #### #    "],
  [54036, 13237873355],
  [504, 500],
  [6070, 20758],
  [825, 26729],
  [6124805, 12555527364986],
  [1915, 2772],
  [5077, 1584927536247],
  [3412, 275],
  [1115, 25056],
  [8028, 8798438007673],
  [256997859093114, 3952288690726],
  [122082, 134076],
  [4091, 1036],
  [253, 794],
  ["2-==10===-12=2-1=-=0", "Merry Christmas"]
]
DAYS = 25

total_time = 0

if ARGV[0]
  day = ARGV[0].to_i
  range = (day..day)
else
  range = (1..DAYS)
end

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
  
  raise "Failed day #{n} part 1. Expected #{SOLUTIONS[n-1][0]} got #{res1}" if SOLUTIONS[n-1][0] != res1
  raise "Failed day #{n} part 2. Expected #{SOLUTIONS[n-1][1]} got #{res2}" if SOLUTIONS[n-1][0] != res1

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