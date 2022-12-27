class Day24
  INPUT = "day24.input"
  DIRECTIONS = [[1, 0], [0, 1], [-1, 0], [0, -1], [0, 0]]

  def initialize
    lines = File.readlines(INPUT, chomp: true)
    @rows = lines.length - 2
    @columns = lines[0].length - 2
    @lcm = @rows.lcm(@columns)
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
    init_state = State.new(start_x, start_y, start, @lcm)
    visited = {}
    queue = [init_state]
    while queue.length > 0
      state = queue.shift
      key = state.key
      DIRECTIONS.each do |dx, dy|
        nx, ny, nmins = [state.x+dx, state.y+dy, state.minutes+1]
        nstate = State.new(nx, ny, nmins, @lcm)
        nkey = nstate.key
        if !visited[nkey] && in_bounds?(nx, ny) && free(nx, ny, nmins)
          visited[nkey] = true
          return nmins + 1 if nx == end_x && ny == end_y
          queue << nstate
        end
      end
    end
  end

  private def in_bounds?(x, y)
    x >= 0 && x < @columns && y >= 0 && y < @rows
  end

  private def free(x, y, minutes)
    minutes = minutes % @lcm

    vert_clash = @clashes[x][y][0].include?(minutes % @rows)
    hor_clash = @clashes[x][y][1].include?(minutes % @columns)
    !vert_clash && !hor_clash    
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
        @clashes[i][j] = [columns.sort, rows.sort]
      end
    end
  end

end

class State
  attr_reader :x, :y, :minutes

  def initialize(x, y, minutes, lcm)
    @x = x
    @y = y
    @minutes = minutes
    @lcm = lcm
  end

  def key
    @key ||= @x + @y*1000 + (@minutes % @lcm)*1000000
  end
end
