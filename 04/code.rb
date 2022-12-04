#!/usr/bin/env ruby

INPUT_FILE = "input"

def parse(input)
  pairs = File.readlines("input", chomp: true)
  pairs.map do |pair|
    pair.split(",").map do |elf|
      elf.split("-").map(&:to_i)
    end
  end
end

def one(assignments)
  count = 0
  assignments.each do |ass|
    count += 1 if (ass[0][0] <= ass[1][0] && ass[0][1] >= ass[1][1]) || (ass[0][0] >= ass[1][0] && ass[0][1] <= ass[1][1])
  end
  count
end

def two(assignments)
  count = 0
  assignments.each do |ass|
    if (ass[0][0] >= ass[1][0] && ass[0][0] <= ass[1][1]) ||
      (ass[0][1] >= ass[1][0] && ass[0][1] <= ass[1][1]) ||
      (ass[1][0] >= ass[0][0] && ass[1][0] <= ass[0][1]) ||
      (ass[1][1] >= ass[0][0] && ass[1][1] <= ass[0][1])
      count += 1 
    end
    
  end
  count
end

assignments = parse(INPUT_FILE)
puts one(assignments)
puts two(assignments)