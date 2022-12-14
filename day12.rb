class Day12
  INPUT = "day12.input"
  MAX_INT = (2**(0.size * 8 -2) -1)
  
  def initialize
    @raw = File.readlines(INPUT, chomp: true).map { |l| l.split("") }
    @m = @raw.length
    @n = @raw[0].length
    calculate_distances
  end

  def one
    @s_dist
  end

  def two
    @min_a_dist
  end

  private def calculate_distances
    @dist = Array.new(@m)
    @visited = Array.new(@m)
    @min_a_dist = MAX_INT
    (0..@m-1).each do |i|
      @dist[i] = Array.new(@n, MAX_INT)
      @visited[i] = Array.new(@n, false)
    end
    
    x, y = root
    queue = [[x, y]]
    @dist[x][y] = 0
    @visited[x][y] = true

    while queue.length > 0
      x, y = queue.shift
      neighbors(x, y).each do |i, j|
        next if @visited[i][j]
        @dist[i][j] = @dist[x][y] + 1
        @s_dist = @dist[i][j] if @raw[i][j] == "S"
        @min_a_dist = [@min_a_dist, @dist[i][j]].min if @raw[i][j] == "a"
        @visited[i][j] = true
        queue << [i, j]
      end
    end
  end

  private def neighbors(i, j)
    nodes = []
    nodes << [i-1, j] if i > 0 && elev(@raw[i][j]) <= elev(@raw[i-1][j]) + 1
    nodes << [i, j-1] if j > 0 && elev(@raw[i][j]) <= elev(@raw[i][j-1]) + 1
    nodes << [i+1, j] if i < @m-1 && elev(@raw[i][j]) <= elev(@raw[i+1][j]) + 1
    nodes << [i, j+1] if j < @n-1 && elev(@raw[i][j]) <= elev(@raw[i][j+1]) + 1
    nodes
  end

  private def root
    (0..@m-1).each do |i|
      (0..@n-1).each do |j|
        return [i,j] if @raw[i][j] == "E"
      end
    end
  end

  private def elev(c)
    c = "a" if c == "S"
    c = "z" if c == "E"
    c.ord
  end
end
