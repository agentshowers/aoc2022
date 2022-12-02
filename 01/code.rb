#!/usr/bin/env ruby

INPUT_FILE = "input"

def parse(input)
    raw = File.read(input).split("\n\n").map { |s| s.split("\n") }
    raw.map { |e| e.map { |c| c.to_i } }
end

def one(elves)
    max_calories = 0
    elves.each do |e|
        calories = e.sum
        max_calories = [max_calories, calories].max
    end
    max_calories
end

def two(elves)
    top = []
    elves.each do |e|
        calories = e.sum
        if top.length != 3
            top << calories
        elsif calories > top[0]
            top[0] = calories
        end
        top.sort!
    end
    top.sum
end

elves = parse(INPUT_FILE)
puts one(elves)
puts two(elves)