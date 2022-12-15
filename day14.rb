class Day14
  INPUT = "day14.input"

  def initialize
    @max_y = 0
    @max_x = 1000
    @rocks = File.readlines(INPUT, chomp: true).map do |l|
      raw = l.split(" -> ")
      raw.map do |r|
        x, y = r.split(",").map(&:to_i)
        @max_y = [y + 3, @max_y].max
        [x, y]
      end
    end
    build_cave
    count_drops
  end

  def one
    @abyss
  end

  def two
    @units
  end

  private def count_drops
    @units = 0
    stack = [[500, 0]]
    @abyss = nil
    while stack.length > 0
      x, y = stack.last
      if @cave[y + 1][x] == "."
        y += 1
        stack << [x, y]
      elsif @cave[y + 1][x - 1] == "."
        y += 1
        x -= 1
        stack << [x, y]
      elsif @cave[y + 1][x + 1] == "."
        y += 1
        x += 1
        stack << [x, y]
      else
        @abyss ||= @units if y == @max_y - 2
        @cave[y][x] = "o"
        @units += 1
        stack.pop
      end
    end
    @units
  end

  private def build_cave
    @cave = Array.new(@max_y)
    (0..@max_y-1).each do |y|
      @cave[y] = Array.new(@max_x, ".")
    end
    @cave[@max_y-1] = Array.new(@max_x, "#")
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