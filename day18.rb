class Day18
  INPUT = "day18.input"
  SIZE = 20

  def initialize
    @cubes = Array.new(SIZE) { Array.new(SIZE) { Array.new(SIZE) { false }}}
    File.readlines(INPUT, chomp: true).each do |line|
      x, y, z = line.split(",").map(&:to_i)
      @cubes[x][y][z] = true
    end
    calculate
  end

  def one
    @exposed_area
  end

  def two
    @exposed_area - @pocket_area
  end

  private def calculate
    @exposed_area = 0
    @pocket_area = 0
    visited_pockets = {}
    @cubes.each_with_index do |plane, x|
      plane.each_with_index do |line, y|
        line.each_with_index do |point, z|
          if point
            @exposed_area += 6 - adjacent(x, y, z).count { |i, j, k| @cubes[i][j][k] }
          elsif !visited_pockets["#{x}-#{y}-#{z}"]
            visited, size = pocket_size(x, y, z)
            visited.keys.each { |k| visited_pockets[k] = true }
            @pocket_area += size
          end
        end
      end
    end
  end

  private def pocket_size(x, y, z)
    size = 0
    queue = [[x, y, z]]
    local_visited = {}
    while queue.length > 0
      i, j, k = queue.pop
      local_visited["#{i}-#{j}-#{k}"] = true
      adjacents = adjacent(i, j, k)
      return [local_visited, 0] if adjacents.count < 6
      adjacents.each do |cx, cy, cz|
        if @cubes[cx][cy][cz]
          size += 1
        elsif !local_visited["#{i}-#{j}-#{k}"]
          queue << [cx, cy, cz]
        end
      end
    end
    [local_visited, size]
  end

  private def adjacent(x, y, z)
    neighbors = []
    neighbors << [x-1, y, z] if x > 0
    neighbors << [x, y-1, z] if y > 0
    neighbors << [x, y, z-1] if z > 0 
    neighbors << [x+1, y, z] if x < SIZE - 1
    neighbors << [x, y+1, z] if y < SIZE - 1
    neighbors << [x, y, z+1] if z < SIZE - 1
    neighbors
  end
end