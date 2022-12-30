class Day23
  INPUT = "day23.input"
  BUFFER = 20
  MAX = 200
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
    @map = Array.new(MAX*MAX)
    @candidates = {}
    id = 0
    File.readlines(INPUT, chomp: true).each_with_index do |line, j|
      line.split("").each_with_index do |s, i|
        if s == "#"
          c = MAX*(i + BUFFER) + (j + BUFFER)
          elf = Elf.new(c, id)
          @map[c] = elf
          @candidates[id] = elf
          initial_neighbors(elf)
          id += 1
        end
      end
    end
    @total_elves = id
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
      if i == 10
        min_x, max_x, min_y, max_y = boundaries
        @p1 = (max_x - min_x + 1) * (max_y - min_y + 1) - @total_elves
      end
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
      if elf.neighbors > 0
        c, dir = possible_move(elf, i)
        if c
          if proposals[c]
            proposals.delete(c)
          else
            proposals[c] = [elf, dir]
          end
        end
      else
        @candidates.delete(elf.id)
      end
    end

    proposals.each do |c, (elf, dir)|
      move(elf, c, dir)
    end
  end

  private def possible_move(elf, round)
    (0..3).each do |i|
      dir_idx = (round+i) % 4
      directions = MOVES[dir_idx]
      if directions.none? { |dx, dy| @map[elf.coordinates + MAX*dx + dy] }
        dx, dy = directions.first
        return [elf.coordinates + MAX*dx + dy, dir_idx]
      end
    end

    nil
  end

  private def move(elf, coordinates, dir)
    recalculate_neighbors(elf, dir, true)

    @map[elf.coordinates] = nil
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
    dir = opposite(dir) if out
    MOVES[dir].each do |dx, dy|
      c = elf.coordinates + MAX*dx + dy
      if @map[c]
        @map[c].neighbors += nx
        @candidates.delete(@map[c].id) if out && @map[c].neighbors == 0
        @candidates[@map[c].id] = @map[c] if !out && @map[c].neighbors == 1
        elf.neighbors += nx
      end
    end
  end

  private def opposite(dir)
    (1 - dir%2) + 2*(dir/2)
  end

  private def initial_neighbors(elf)
    DIRECTIONS.values.map do |dx, dy|
      c = elf.coordinates + MAX*dx + dy
      if @map[c]
        elf.neighbors += 1
        @map[c].neighbors += 1
      end
    end
  end
  
  private def boundaries
    min_x, max_x, min_y, max_y = [MAX, 0, MAX, 0]
    @map.each_with_index do |elf, i|
      if elf
        x = i / MAX
        y = i % MAX
        min_x = [x, min_x].min
        max_x = [x, max_x].max
        min_y = [y, min_y].min
        max_y = [y, max_y].max
      end
    end
    [min_x, max_x, min_y, max_y]
  end

  def print
    min_x, max_x, min_y, max_y = boundaries
    (min_y..max_y).each do |y|
      str = ""
      (min_x..max_x).each do |x|
        if @map[MAX*x + y]
          str << @map[MAX*x + y].neighbors.to_s
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