class Day15
  INPUT = "day15.input"
  LINE = 2000000
  MAX = 4000000

  def initialize
    @sensors = File.readlines(INPUT, chomp: true).map do |line|
      line =~ /Sensor at x=(\-?\d+), y=(\-?\d+): closest beacon is at x=(\-?\d+), y=(\-?\d+)/
      [$1.to_i, $2.to_i, $3.to_i, $4.to_i]
    end
  end

  def one
    range = []
    beacons = []
    @sensors.each do |s_x, s_y, b_x, b_y|
      dist = (s_x - b_x).abs + (s_y - b_y).abs
      next if LINE < s_y - dist || LINE > s_y + dist
      diff = dist - (s_y - LINE).abs
      range = merge(range, s_x - diff, s_x + diff, false)
      beacons << b_x if b_y == LINE
    end
    range.first[1] - range.first[0] + 1 - beacons.uniq.count
  end

  def two
    intersect_edges
    x, y = @intersections.uniq.select do |x, y|
      @sensors.none? { |s_x, s_y, b_x, b_y| in_range?(s_x, s_y, b_x, b_y, x, y) }
    end.first
    x.to_i * 4000000 + y.to_i
  end

  private def intersect_edges
    lines = []
    @intersections = []
    @sensors.each do |s_x, s_y, b_x, b_y|
      dist = (s_x - b_x).abs + (s_y - b_y).abs
      lines << [1, s_y - s_x + dist + 1]
      lines << [1, s_y - s_x - dist - 1]
      lines << [-1, s_y + s_x + dist + 1]
      lines << [-1, s_y + s_x - dist - 1]
    end
    i = 0
    while i < lines.length do
      j = i + 1
      while j < lines.length do
        if lines[i][0] != lines[j][0]
          x = (1.0 * (lines[j][1] - lines[i][1]))/(lines[i][0] - lines[j][0])
          y = (1.0 * (lines[i][0]*lines[j][1] - lines[j][0]*lines[i][1]))/(lines[i][0] - lines[j][0])
          @intersections << [x, y] if x % 1 == 0 && y % 1 == 0 && x >= 0 && x <= MAX && y >= 0 && y <= MAX
        end
        j += 1
      end
      i += 1
    end
  end

  private def in_range?(s_x, s_y, b_x, b_y, x, y)
    dist_b = (s_x - b_x).abs + (s_y - b_y).abs
    dist = (s_x - x).abs + (s_y - y).abs
    dist_b >= dist
  end

  private def merge(range, r_start, r_end, limits=true)
    r_start = [r_start, 0].max if limits
    r_end = [r_end, MAX].min if limits
    if !range
      new_range = [[r_start, r_end]]
    else
      new_range = []
      i = 0
      inserted = false
      while !inserted do
        if i == range.length
          new_range << [r_start, r_end]
          inserted = true
        elsif r_end < range[i][0] - 1
          new_range << [r_start, r_end]
          new_range += range[i..]
          inserted = true
        elsif r_start > range[i][1] + 1
          new_range << range[i]
          i += 1
        else
          new_start = [r_start, range[i][0]].min
          new_end = [r_end, range[i][1]].max
          i += 1
          if i < range.length && new_end >= range[i][0]
            new_end = [r_end, range[i][1]].max
            i += 1
          end
          new_range << [new_start, new_end]
          new_range += range[i..]
          inserted = true

        end
      end
    end
    new_range
  end

end

