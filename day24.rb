require 'rb_heap'

class Day24
  INPUT = "day24.input"
  DIRECTIONS = [[1, 0], [0, 1], [-1, 0], [0, -1], [0, 0]]

  def initialize
    lines = File.readlines(INPUT, chomp: true)
    @rows = lines.length - 2
    @columns = lines[0].length - 2
    @row_patterns = Array.new(@rows) { [] }
    @column_patterns = Array.new(@columns) { [] }
    @lcm = @rows.lcm(@columns)

    lines.each_with_index do |line, j|
      next if j == 0 || j > @rows
      line.chars.each_with_index do |c, i|
        next if i == 0 || i > @columns
        @row_patterns[j-1] << [i-1, 1] if c == ">"
        @row_patterns[j-1] << [i-1, -1] if c == "<"
        @column_patterns[i-1] << [j-1, 1] if c == "v"
        @column_patterns[i-1] << [j-1, -1] if c == "^"
      end
    end
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
    heap = Heap.new do |a, b|
      (end_x - a.x).abs + (end_y - a.y).abs + a.minutes < (end_x - b.x).abs + (end_y - b.y).abs + b.minutes
    end
    heap << init_state
    visited = {}
    dist = { init_state.key => start }
    while heap.size > 0
      state = heap.pop
      key = state.key
      DIRECTIONS.each do |dx, dy|
        nx, ny, nmins = [state.x+dx, state.y+dy, state.minutes+1]
        nstate = State.new(nx, ny, nmins, @lcm)
        nkey = nstate.key
        if !visited[nkey] && in_bounds?(nx, ny) && free(nx, ny, nmins)
          visited[nkey] = true
          return dist[key] + 2 if nx == end_x && ny == end_y
          heap << nstate
          dist[nkey] = dist[key] + 1
        end
      end
    end
  end

  private def fastest_solution(x, y, end_x, end_y, minutes)
    (end_x - x).abs + (end_y - y).abs + minutes
  end

  private def in_bounds?(x, y)
    x >= 0 && x < @columns && y >= 0 && y < @rows
  end

  private def free(x, y, minutes)
    vert_free = @column_patterns[x].none? { |j, d| (j + minutes*d) % @rows == y }
    hor_free = @row_patterns[y].none? { |i, d| (i + minutes*d) % @columns == x }
    vert_free && hor_free
  end

  private def encode(x, y, minutes)
    x + y*1000 + (minutes % @lcm)*1000000
  end
end

class State
  attr_reader :x, :y, :minutes

  def initialize(x, y, minutes, lcm)
    @x = x
    @y = y
    @minutes = minutes % lcm
  end

  def key
    @x + @y*1000 + @minutes*1000000
  end
end
