class Day22
  INPUT = "day22.input"

  DIRECTIONS = {
    "R" => [0, 1],
    "D" => [1, 0],
    "L" => [0, -1],
    "U" => [-1, 0]
  } 

  def initialize
    m, i = File.read(INPUT).split("\n\n")
    lines = m.split("\n")
    @max_y = lines.length
    @max_x = lines.map { |l| l.length }.max
    @map = Array.new(@max_y)
    lines.each_with_index do |line, idx|
      @map[idx] = line.ljust(@max_x, " ").chars
    end
    @instructions = i.split(/[RL]/).map(&:to_i).zip(i.strip.split(/\d+/)[1..])
  end

  def one
    run do |y, x, direction|
      unfolded(y, x, direction)
    end
  end

  def two
    run do |y, x, direction|
      folded(y, x, direction)
    end
  end

  private def run
    x = @map[0].index { |p| p != " " }
    y = 0
    direction = "R"
    @instructions.each do |steps, rotation|
      i = 0
      while i < steps do
        ny, nx, dir = yield(y, x, direction)

        break if @map[ny][nx] == "#"
        y = ny
        x = nx
        direction = dir
        i += 1
      end
      direction = rotate(direction, rotation)
    end

    (1000 * (y + 1)) + (4 * (x + 1)) + DIRECTIONS.keys.index(direction)
  end

  private def rotate(direction, rotation)
    idx = DIRECTIONS.keys.index(direction)
    idx = (idx + 1) % 4 if rotation == "R"
    idx = (idx - 1) % 4 if rotation == "L"
    DIRECTIONS.keys[idx]
  end

  private def unfolded(y, x, direction)
    dy, dx = DIRECTIONS[direction]
    if dy.abs > 0
      if y + dy == @max_y || y + dy == -1 || @map[y + dy][x] == " "
        y = dy > 0 ? 0 : @max_y - 1
        while @map[y][x] == " " do
          y += dy
        end
      else
        y += dy
      end
    else
      if x + dx == @max_x || x + dx == -1 || @map[y][x + dx] == " " 
        x = dx > 0 ? 0 : @max_x - 1
        while @map[y][x] == " " do
          x += dx
        end
      else
        x += dx
      end
    end
    
    [y, x, direction]
  end

  private def folded(y, x, direction)
    case direction
    when "D"
      fold_down(y, x)
    when "U"
      fold_up(y, x)
    when "R"
      fold_right(y, x)
    when "L"
      fold_left(y, x)
    end
  end

  private def fold_down(y, x)
    side = @max_y / 4
    direction = "D"

    if y == @max_y - 1 # Moving down from cube 6 to cube 2
      new_y = 0
      new_x = x + 2*side
    elsif @map[y + 1][x] == " " 
      if x < 2*side  # Moving down from cube 4 to cube 6
        direction = "L"
        new_y = x + 2*side
        new_x = side - 1
      else  # Moving down from cube 2 to cube 3
        direction = "L"
        new_y = x - side
        new_x = 2*side - 1
      end
    else
      new_y = y + 1
      new_x = x
    end

    [new_y, new_x, direction]
  end

  private def fold_up(y, x)
    side = @max_y / 4
    direction = "U"

    if y == 0
      if x < 2*side # Moving upfrom cube 1 to cube 6
        direction = "R"
        new_y = x + 2*side
        new_x = 0
      else # Moving upfrom cube 2 to cube 6
        new_y = @max_y - 1
        new_x = x - 2*side
      end
    elsif @map[y - 1][x] == " " # Moving up from cube 5 to cube 3
      direction = "R"
      new_y = x + side
      new_x = side
    else
      new_y = y - 1
      new_x = x
    end
    [new_y, new_x, direction]
  end

  private def fold_right(y, x)
    side = @max_y / 4
    direction = "R"

    if x == @max_x - 1 # Moving right from cube 2 to cube 4
      direction = "L"
      new_y = 3*side - y - 1
      new_x = 2*side - 1
    elsif @map[y][x + 1] == " "
      if y < 2*side # Moving right from cube 3 to cube 2
        direction = "U"
        new_y = side - 1
        new_x = y + side
      elsif y < 3*side # Moving right from cube 4 to cube 2
        direction = "L"
        new_y = 3*side - y - 1
        new_x = 3*side - 1
      else # Moving right from cube 6 to cube 4
        direction = "U"
        new_y = 3*side - 1
        new_x = y - 2*side
      end
    else
      new_x = x + 1
      new_y = y
    end

    [new_y, new_x, direction]
  end

  private def fold_left(y, x)
    side = @max_y / 4
    direction = "L"

    if x == 0
      if y < 3*side # Moving left from cube 5 to cube 1
        direction = "R"
        new_y = 3*side - y - 1
        new_x = side
      else # Moving left from cube 6 to cube 1
        direction = "D"
        new_y = 0
        new_x = y - 2*side
      end
    elsif @map[y][x - 1] == " "
      if y < side # Moving left from cube 1 to cube 5
        direction = "R"
        new_y = 3*side - y - 1
        new_x = 0
      else # Moving left from cube 3 to cube 5
        direction = "D"
        new_y = 2*side
        new_x = y - side
      end
    else
      new_x = x - 1
      new_y = y
    end

    [new_y, new_x, direction]
  end

end
