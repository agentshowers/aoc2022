class Day12
  INPUT = "day12.input"
  MAX_INT = (2**(0.size * 8 -2) -1)
  
  def initialize
    @raw = File.readlines(INPUT, chomp: true).map { |l| l.split("") }
    @m = @raw.length
    @n = @raw[0].length
    build_map
    calculate_distances
  end

  def one
    x, y = find("S").first
    @dist[x][y]
  end

  def two
    find("a").map { |i,j| @dist[i][j] }.min
  end

  private def build_map
    @map = Array.new(@m)
    (0..@m-1).each do |i|
      @map[i] = Array.new(@n)
      (0..@n-1).each do |j|
          nodes = []
          nodes << [i-1, j] if i > 0 && elev(@raw[i][j]) <= elev(@raw[i-1][j]) + 1
          nodes << [i, j-1] if j > 0 && elev(@raw[i][j]) <= elev(@raw[i][j-1]) + 1
          nodes << [i+1, j] if i < @m-1 && elev(@raw[i][j]) <= elev(@raw[i+1][j]) + 1
          nodes << [i, j+1] if j < @n-1 && elev(@raw[i][j]) <= elev(@raw[i][j+1]) + 1
          @map[i][j] = nodes
      end
    end
  end

  private def calculate_distances
    @dist = Array.new(@m)
    @visited = Array.new(@m)
    (0..@m-1).each do |i|
      @dist[i] = Array.new(@n, MAX_INT)
      @visited[i] = Array.new(@n, false)
    end
    queue = []
    dest_x, dest_y = find("E").first
    @dist[dest_x][dest_y] = 0
    queue << [dest_x, dest_y]
    @visited[dest_x][dest_y] = 0

    while queue.length > 0
      x, y = queue.shift
      @map[x][y].each do |i, j|
        next if @visited[i][j]
        @dist[i][j] = @dist[x][y] + 1
        @visited[i][j] = true
        queue << [i, j]
      end
    end
  end

  private def find(c)
    positions = []
    (0..@m-1).each do |i|
      (0..@n-1).each do |j|
        positions << [i,j] if @raw[i][j] == c
      end
    end
    positions
  end

  private def elev(c)
    c = "a" if c == "S"
    c = "z" if c == "E"
    c.ord
  end
end
