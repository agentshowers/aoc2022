
class Day14
  INPUT = "day14.input"

  def initialize
    @max_y = 0
    @rocks = File.readlines(INPUT, chomp: true).map do |l|
      raw = l.split(" -> ")
      raw.map do |r|
        x, y = r.split(",").map(&:to_i)
        @max_y = [y + 3, @max_y].max
        [x, y]
      end
    end
    @max_x = 1000
  end

  def one
    build_cave
    count_drops
  end

  def two
    build_cave
    @cave[@max_y-1] = Array.new(@max_x, "#")
    count_drops
  end

  private def count_drops
    units = 0
    loop do
      if drop_sand
        break
      else
        units += 1
      end
    end
    units
  end

  private def drop_sand
    x = 500
    y = 0
    stopped = false
    return true if @cave[y][x] == "o"
  
    while !stopped
      return true if y == @max_y - 1
      if @cave[y + 1][x] == "."
        y += 1
      elsif @cave[y + 1][x - 1] == "."
        y += 1
        x -= 1
      elsif @cave[y + 1][x + 1] == "."
        y += 1
        x += 1
      else
        stopped = true
        @cave[y][x] = "o"
      end
    end
    false
  end

  private def build_cave
    @cave = Array.new(@max_y)
    (0..@max_y-1).each do |y|
      @cave[y] = Array.new(@max_x, ".")
    end
    @rocks.each do |rock_line|
      i = 1
      while i < rock_line.length
        start_x, start_y = rock_line[i-1]
        end_x, end_y = rock_line[i]
        diff_x = (end_x - start_x) <=> 0
        diff_y = (end_y - start_y) <=> 0
        @cave[start_y][start_x] = "#"
        loop do
          start_x += diff_x
          start_y += diff_y
          @cave[start_y][start_x] = "#"
          break if start_x == end_x && start_y == end_y
        end
        i += 1
      end
    end
  end

  private def print
    File.write("cave", @cave.map { |r| r.join("") }.join("\n"))
  end
end