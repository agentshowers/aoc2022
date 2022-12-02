#!/usr/bin/env ruby

INPUT_FILE = "input"

def parse(input)
    File.readlines("input", chomp: true).map {|l| l.split(" ")}
end

def one(strategy)
    points = 0
    strategy.each do |s|
    play = (s[1].ord - 23).chr
    result = (play.ord - s[0].ord + 1) % 3
    points += play.ord - 64 + result*3
    end
    points
end

def two(strategy)
    points = 0
    strategy.each do |s|
    case s[1]
    when "X"
        play = (s[0].ord - 1 == 64 ? 67 : s[0].ord - 1).chr
    when "Y"
        play = s[0]
        points += 3
    when "Z"
        play = (s[0].ord + 1 == 68 ? 65 : s[0].ord + 1).chr
        points += 6
    end
    points += play.ord - 64
    end
    points
end

strategy = parse(INPUT_FILE)
puts one(strategy)
puts two(strategy)