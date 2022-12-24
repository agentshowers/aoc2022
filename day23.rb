class Day23
  INPUT = "day23.input"
  BUFFER = 50
  DIRECTIONS = {
    "NW" => [-1, -1],
    "N" => [0, -1],
    "NE" =>  [1, -1],
    "E" => [1, 0],
    "SE" => [1, 1],
    "S" => [0, 1],
    "SW" => [-1, 1],
    "W" => [-1, 0]
  }
  MOVES = [
    [DIRECTIONS["N"], DIRECTIONS["NW"], DIRECTIONS["NE"]],
    [DIRECTIONS["S"], DIRECTIONS["SW"], DIRECTIONS["SE"]],
    [DIRECTIONS["W"], DIRECTIONS["SW"], DIRECTIONS["NW"]],
    [DIRECTIONS["E"], DIRECTIONS["SE"], DIRECTIONS["NE"]],
  ]

  def initialize
    @min_x = 10000
    @max_x = 0
    @min_y = 10000
    @max_y = 0
    @map = {}
    @candidates = {}
    id = 0
    File.readlines(INPUT, chomp: true).each_with_index do |line, j|
      line.split("").each_with_index do |s, i|
        if s == "#"
          c = 10000*(i + BUFFER) + (j + BUFFER)
          elf = Elf.new(c, id)
          @map[c] = elf
          @candidates[id] = elf
          initial_neighbors(elf)
          boundaries(i + BUFFER, j + BUFFER)
          id += 1
        end
      end
    end
    rounds
  end

  def one
    @p1
  end

  def two
    @p2
  end

  private def rounds
    i = 0
    loop do
      @p1 = (@max_x - @min_x + 1) * (@max_y - @min_y + 1) - @map.values.length if i == 10
      round(i)
      i += 1
      if @candidates.empty?
        @p2 = i + 1
        break
      end
    end
  end

  private def round(i)
    proposals = {}

    @candidates.values.each do |elf|
      if elf.neighbors > 0 && elf.neighbors < 6
        c, dir = possible_move(elf, i)
        proposals[c] = (proposals[c] || []) + [[elf, dir]] if c
      else
        @candidates.delete(elf.id)
      end
    end

    proposals.each do |c, elves|
      if elves.length == 1
        elf, dir = elves.first
        move(elf, dir)
        boundaries(c / 10000, c % 10000)
      end
    end
  end

  private def possible_move(elf, round)
    (0..3).each do |i|
      dir_idx = (round+i) % 4
      directions = MOVES[dir_idx]
      if directions.none? { |dx, dy| @map[elf.coordinates + 10000*dx + dy] }
        dx, dy = directions.first
        return [elf.coordinates + 10000*dx + dy, dir_idx]
      end
    end

    nil
  end

  private def move(elf, dir)
    dx, dy = MOVES[dir][0]
    coordinates = elf.coordinates + 10000*dx + dy
    recalculate_neighbors(elf, dir, true)

    @map.delete(elf.coordinates)
    elf.coordinates = coordinates
    @map[coordinates] = elf
  
    recalculate_neighbors(elf, dir, false)

    if elf.neighbors == 0
      @candidates.delete(elf.id)
    else
      @candidates[elf.id] = elf
    end
  end

  private def recalculate_neighbors(elf, dir, out)
    nx = out ? -1 : 1
    del_threshold = out ? 0 : 6
    add_threshold = out ? 5 : 1
    dir = opposite(dir) if out
    MOVES[dir].each do |dx, dy|
      c = elf.coordinates + 10000*dx + dy
      if @map[c]
        @map[c].neighbors += nx
        @candidates.delete(@map[c].id) if @map[c].neighbors == del_threshold
        @candidates[@map[c].id] = @map[c] if @map[c].neighbors == add_threshold
        elf.neighbors += nx
      end
    end
  end

  private def opposite(dir)
    (1 - dir%2) + 2*(dir/2)
  end

  private def initial_neighbors(elf)
    DIRECTIONS.values.map do |dx, dy|
      c = elf.coordinates + 10000*dx + dy
      if @map[c]
        elf.neighbors += 1
        @map[c].neighbors += 1
      end
    end
  end
  
  private def boundaries(x, y)
    @min_x = [x, @min_x].min
    @max_x = [x, @max_x].max
    @min_y = [y, @min_y].min
    @max_y = [y, @max_y].max
  end

  def print
    (@min_y..@max_y).each do |y|
      str = ""
      (@min_x..@max_x).each do |x|
        if @map[10000*x + y]
          str << @map[10000*x + y].neighbors.to_s
        else
          str << "."
        end
      end
      puts str
    end
  end
  
end

class Elf
  attr_accessor :coordinates, :neighbors
  attr_reader :id

  def initialize(coordinates, id)
    @id = id
    @coordinates = coordinates
    @neighbors = 0
  end

end