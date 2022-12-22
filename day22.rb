class Day22
  INPUT = "day22.input"

  def initialize
    m, inst = File.read(INPUT).split("\n\n")
    lines = m.split("\n")
    max_y = lines.length
    max_x = lines.map { |l| l.length }.max
    lines.map! { |line| line.ljust(max_x, " ") }
    cube_size = [max_x, max_y].max / 4
    @cubes = []
    (0..(max_y / cube_size) - 1).each do |y|
      (0..(max_x / cube_size) - 1).each do |x|
        j = y * cube_size
        i = x  * cube_size
        if lines[j][i] != " "
          map = lines[j..(j+cube_size-1)].map { |l| l[i..(i+cube_size-1)] }
          cube = Cube.new(cube_size, y, x, map)
          @cubes << cube
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
    @cubes.each do |cube|
      left_cube = @cubes.find { |c| c.grid_y == cube.grid_y && c.grid_x == cube.grid_x - 1} || @cubes.select { |c| c.grid_y == cube.grid_y }.last
      cube.left = [left_cube, "L"]
      
      right_cube = @cubes.find { |c| c.grid_y == cube.grid_y && c.grid_x == cube.grid_x + 1} || @cubes.select { |c| c.grid_y == cube.grid_y }.first
      cube.right = [right_cube, "R"]

      up_cube = @cubes.find { |c| c.grid_y == cube.grid_y - 1 && c.grid_x == cube.grid_x } || @cubes.select { |c| c.grid_x == cube.grid_x }.last
      cube.up = [up_cube, "U"]

      down_cube = @cubes.find { |c| c.grid_y == cube.grid_y + 1 && c.grid_x == cube.grid_x } || @cubes.select { |c| c.grid_x == cube.grid_x }.first
      cube.down = [down_cube, "D"]
    end
  end

  private def folded_adjacencies
    # TODO: become smart enough to write a folding cube algorithm

    @cubes[0].right = [@cubes[1], "R"]
    @cubes[0].down = [@cubes[2], "D"]
    @cubes[0].left = [@cubes[3], "R"]
    @cubes[0].up = [@cubes[5], "R"]

    @cubes[1].right = [@cubes[4], "L"]
    @cubes[1].down = [@cubes[2], "L"]
    @cubes[1].left = [@cubes[0], "L"]
    @cubes[1].up = [@cubes[5], "U"]

    @cubes[2].right = [@cubes[1], "U"]
    @cubes[2].down = [@cubes[4], "D"]
    @cubes[2].left = [@cubes[3], "D"]
    @cubes[2].up = [@cubes[0], "U"]

    @cubes[3].right = [@cubes[4], "R"]
    @cubes[3].down = [@cubes[5], "D"]
    @cubes[3].left = [@cubes[0], "R"]
    @cubes[3].up = [@cubes[2], "R"]

    @cubes[4].right = [@cubes[1], "L"]
    @cubes[4].down = [@cubes[5], "L"]
    @cubes[4].left = [@cubes[3], "L"]
    @cubes[4].up = [@cubes[2], "U"]

    @cubes[5].right = [@cubes[4], "U"]
    @cubes[5].down = [@cubes[1], "D"]
    @cubes[5].left = [@cubes[0], "D"]
    @cubes[5].up = [@cubes[3], "U"]
  end

  private def solve
    x = 0
    y = 0
    cube = @cubes.first
    direction = "R"
    @instructions.each do |steps, rotation|
      (1..steps).each do
        new_cube, new_y, new_x, new_dir = cube.move(direction, y, x)
        break if new_cube.wall?(new_y, new_x)
        cube, y, x, direction = [new_cube, new_y, new_x, new_dir]
      end
      direction = rotate(direction, rotation)
    end

    cube.password(y, x, direction)
  end

  private def rotate(direction, rotation)
    idx = Cube::DIRECTIONS.keys.index(direction)
    idx = (idx + 1) % 4 if rotation == "R"
    idx = (idx - 1) % 4 if rotation == "L"
    Cube::DIRECTIONS.keys[idx]
  end

end

class Cube
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
      cube = self
      new_dir = direction
    else
      cube, new_dir = neighbors[direction]
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
    [cube, new_y, new_x, new_dir]
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