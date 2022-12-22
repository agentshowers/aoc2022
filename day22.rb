class Day22
  INPUT = "day22.input"

  def initialize
    m, inst = File.read(INPUT).split("\n\n")
    lines = m.split("\n")
    max_y = lines.length
    max_x = lines.map { |l| l.length }.max
    lines.map! { |line| line.ljust(max_x, " ") }
    square_size = [max_x, max_y].max / 4
    @squares = []
    (0..(max_y / square_size) - 1).each do |y|
      (0..(max_x / square_size) - 1).each do |x|
        j = y * square_size
        i = x  * square_size
        if lines[j][i] != " "
          map = lines[j..(j+square_size-1)].map { |l| l[i..(i+square_size-1)] }
          square = Square.new(square_size, y, x, map)
          @squares << square
        end
      end
    end
    @instructions = inst.split(/[RL]/).map(&:to_i).zip(inst.strip.split(/\d+/)[1..])
  end

  def one
    unfolded_adjacencies
    solve
  end

  def two
    folded_adjacencies
    solve
  end

  private def unfolded_adjacencies
    @squares.each do |square|
      left_square = @squares.find { |c| c.grid_y == square.grid_y && c.grid_x == square.grid_x - 1} || @squares.select { |c| c.grid_y == square.grid_y }.last
      square.left = [left_square, "L"]
      
      right_square = @squares.find { |c| c.grid_y == square.grid_y && c.grid_x == square.grid_x + 1} || @squares.select { |c| c.grid_y == square.grid_y }.first
      square.right = [right_square, "R"]

      up_square = @squares.find { |c| c.grid_y == square.grid_y - 1 && c.grid_x == square.grid_x } || @squares.select { |c| c.grid_x == square.grid_x }.last
      square.up = [up_square, "U"]

      down_square = @squares.find { |c| c.grid_y == square.grid_y + 1 && c.grid_x == square.grid_x } || @squares.select { |c| c.grid_x == square.grid_x }.first
      square.down = [down_square, "D"]
    end
  end

  private def folded_adjacencies
    # TODO: become smart enough to write a cube folding algorithm

    @squares[0].right = [@squares[1], "R"]
    @squares[0].down = [@squares[2], "D"]
    @squares[0].left = [@squares[3], "R"]
    @squares[0].up = [@squares[5], "R"]

    @squares[1].right = [@squares[4], "L"]
    @squares[1].down = [@squares[2], "L"]
    @squares[1].left = [@squares[0], "L"]
    @squares[1].up = [@squares[5], "U"]

    @squares[2].right = [@squares[1], "U"]
    @squares[2].down = [@squares[4], "D"]
    @squares[2].left = [@squares[3], "D"]
    @squares[2].up = [@squares[0], "U"]

    @squares[3].right = [@squares[4], "R"]
    @squares[3].down = [@squares[5], "D"]
    @squares[3].left = [@squares[0], "R"]
    @squares[3].up = [@squares[2], "R"]

    @squares[4].right = [@squares[1], "L"]
    @squares[4].down = [@squares[5], "L"]
    @squares[4].left = [@squares[3], "L"]
    @squares[4].up = [@squares[2], "U"]

    @squares[5].right = [@squares[4], "U"]
    @squares[5].down = [@squares[1], "D"]
    @squares[5].left = [@squares[0], "D"]
    @squares[5].up = [@squares[3], "U"]
  end

  private def solve
    x = 0
    y = 0
    square = @squares.first
    direction = "R"
    @instructions.each do |steps, rotation|
      (1..steps).each do
        new_square, new_y, new_x, new_dir = square.move(direction, y, x)
        break if new_square.wall?(new_y, new_x)
        square, y, x, direction = [new_square, new_y, new_x, new_dir]
      end
      direction = rotate(direction, rotation)
    end

    square.password(y, x, direction)
  end

  private def rotate(direction, rotation)
    idx = Square::DIRECTIONS.keys.index(direction)
    idx = (idx + 1) % 4 if rotation == "R"
    idx = (idx - 1) % 4 if rotation == "L"
    Square::DIRECTIONS.keys[idx]
  end

end

class Square
  attr_reader :size, :grid_y, :grid_x
  attr_accessor :left, :right, :up, :down

  DIRECTIONS = {
    "R" => [0, 1],
    "D" => [1, 0],
    "L" => [0, -1],
    "U" => [-1, 0]
  } 

  def initialize(size, grid_y, grid_x, map)
    @size = size
    @grid_y = grid_y
    @grid_x = grid_x
    @map = map
  end

  def move(direction, j, i)
    dy, dx = DIRECTIONS[direction]
    if j + dy >= 0 && j + dy < size && i + dx >= 0 && i + dx < size
      new_y = j + dy
      new_x = i + dx
      square = self
      new_dir = direction
    else
      square, new_dir = neighbors[direction]
      case direction
      when "R"
        new_y = j
        new_x = 0
      when "D"
        new_y = 0
        new_x = i
      when "L"
        new_y = j
        new_x = size - 1
      when "U"
        new_y = size - 1
        new_x = i
      end
      idx_move = DIRECTIONS.keys.index(direction)
      idx_dir = DIRECTIONS.keys.index(new_dir)
      rotations = (idx_dir - idx_move) % 4
      (1..rotations).each do
        tmp = new_x
        new_x = size - new_y - 1
        new_y = tmp
      end
    end
    [square, new_y, new_x, new_dir]
  end

  def wall?(y, x)
    @map[y][x] == "#"
  end

  def password(y, x, direction)
    1000 * (grid_y * @size + y + 1) + 4 * (grid_x * @size + x + 1) + DIRECTIONS.keys.index(direction)
  end

  private def neighbors
    { "R" => right, "D" => down, "L" => left, "U" => up }
  end

end