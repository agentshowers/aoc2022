class Day23
  INPUT = "day23.input"
  BUFFER = 50

  def initialize
    @min_x = 10000
    @max_x = 0
    @min_y = 10000
    @max_y = 0
    @map = {}
    File.readlines(INPUT, chomp: true).each_with_index do |line, j|
      line.split("").each_with_index do |s, i|
        if s == "#"

          c = 10000*(i + BUFFER) + (j + BUFFER)
          elf = Elf.new(c)
          @map[c] = elf
          elf.recalculate_neighbors(@map)
          boundaries(i + BUFFER, j + BUFFER)
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
      if @map.values.none? { |elf| elf.neighbors > 0 }
        @p2 = i + 1
        break
      end
    end
  end

  private def round(i)
    proposals = {}
    @map.values.each do |elf|
      if elf.neighbors > 0
        c = elf.candidate_move(@map, i % 4)
        proposals[c] = (proposals[c] || []) + [elf] if c
      end
    end
    proposals.each do |c, elves|
      if elves.length == 1
        elves.first.move(@map, c) 
        boundaries(c / 10000, c % 10000)
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

  NEIGHBORS = [
    [1, -1],
    [1, 0],
    [1, 1],
    [0, -1],
    [0, 1],
    [-1, -1],
    [-1, 0],
    [-1, 1]
  ]
  DIRECTIONS = [
    [[0, -1], [-1, -1], [1, -1]],
    [[0, 1], [-1, 1], [1, 1]],
    [[-1, 0], [-1, -1], [-1, 1]],
    [[1, 0], [1, -1], [1, 1]]
  ]

  def initialize(coordinates)
    @coordinates = coordinates
    @neighbors = 0
  end

  def move(map, new_c)
    neighbor_locations.each do |c|
      map[c].neighbors -= 1 if map[c]
    end
    map.delete(coordinates)
    @coordinates = new_c
    map[coordinates] = self
    recalculate_neighbors(map)
  end

  def recalculate_neighbors(map)
    @neighbors = 0
    neighbor_locations.each do |c|
      if map[c]
        @neighbors += 1
        map[c].neighbors += 1
      end
    end
  end

  def candidate_move(map, i)
    (0..3).each do |j|
      direction = DIRECTIONS[(i+j) % 4]
      if direction.none? { |dx, dy| map[coordinates + 10000*dx + dy] }
        dx, dy = direction.first
        return coordinates + 10000*dx + dy
      end
    end

    nil
  end

  private def neighbor_locations
    NEIGHBORS.map do |dx, dy|
      coordinates + 10000*dx + dy
    end
  end

  def to_s
    "#"
  end
end