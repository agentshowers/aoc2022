class Day1
  INPUT = "day01.input"

  def initialize
    raw = File.read(INPUT).split("\n\n").map { |s| s.split("\n") }
    @elves = raw.map { |e| e.map { |c| c.to_i } }
  end

  def one
    max_calories = 0
    @elves.each do |e|
        calories = e.sum
        max_calories = [max_calories, calories].max
    end
    max_calories
  end

  def two
    top = []
    @elves.each do |e|
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
end
