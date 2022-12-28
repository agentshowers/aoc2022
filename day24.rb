class Day24
  INPUT = "day24.input"

  def initialize
    lines = File.readlines(INPUT, chomp: true)
    @rows = lines.length - 2
    @columns = lines[0].length - 2
    @lcm = @rows.lcm(@columns)
    precompute_neighbors
    precompute_patterns(lines)
  end

  def one
    @first_trip = bfs(0, 0, @columns - 1, @rows - 1, 0)
    @first_trip
  end

  def two
    second_trip = bfs(@columns - 1, @rows - 1, 0, 0, @first_trip)
    bfs(0, 0, @columns - 1, @rows - 1, second_trip)
  end

  private def bfs(start_x, start_y, end_x, end_y, start)
    loop do
      start += 1
      break if free(start_x, start_y, start)
    end
    init_state = [start_x, start_y, start]
    visited = {}
    queue = [init_state]
    while queue.length > 0
      x, y, minutes = queue.shift
      @neighbors[x][y].each do |nx, ny|
        nmins = minutes+1
        nstate = [nx, ny, nmins]
        if !visited[nstate] && free(nx, ny, nmins)
          visited[nstate] = true
          return nmins + 1 if nx == end_x && ny == end_y
          queue << nstate
        end
      end
    end
  end

  private def free(x, y, minutes)
    minutes = minutes % @lcm

    return false if @clashes[x][y][0].include?(minutes % @rows)
    !@clashes[x][y][1].include?(minutes % @columns)
  end

  private def precompute_neighbors
    @neighbors = Array.new(@columns) { Array.new(@rows) { [] } }
    (0..@columns-1).each do |i|
      (0..@rows-1).each do |j|
        @neighbors[i][j] << [i, j]
        @neighbors[i][j] << [i+1, j] if i < @columns - 1
        @neighbors[i][j] << [i-1, j] if i > 0
        @neighbors[i][j] << [i, j+1] if j < @rows - 1
        @neighbors[i][j] << [i, j-1] if j > 0
      end
    end
  end

  private def precompute_patterns(lines)
    row_patterns = Array.new(@rows) { [] }
    column_patterns = Array.new(@columns) { [] }
    lines.each_with_index do |line, j|
      next if j == 0 || j > @rows
      line.chars.each_with_index do |c, i|
        next if i == 0 || i > @columns
        row_patterns[j-1] << [i-1, 1] if c == ">"
        row_patterns[j-1] << [i-1, -1] if c == "<"
        column_patterns[i-1] << [j-1, 1] if c == "v"
        column_patterns[i-1] << [j-1, -1] if c == "^"
      end
    end
    @clashes = Array.new(@columns) { Array.new(@rows) { [] } }
    (0..@columns-1).each do |i|
      (0..@rows-1).each do |j|
        columns = column_patterns[i].map { |y, d| (j-y)*d % @rows }
        rows = row_patterns[j].map { |x, d| (i-x)*d % @columns }
        @clashes[i][j] = [columns, rows]
      end
    end
  end

end
