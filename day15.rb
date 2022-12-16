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
      merge(range, s_x - diff, s_x + diff)
      beacons << b_x if b_y == LINE
    end
    
    range.each_slice(2).map { |s| s[1] + 1 - s[0] }.sum - beacons.uniq.count
  end

  def two
    x, y = find_intersection
    x.to_i * 4000000 + y.to_i
  end

  private def find_intersection
    positive_slopes = []
    negative_slopes = []
    @sensors.each do |s_x, s_y, b_x, b_y|
      dist = (s_x - b_x).abs + (s_y - b_y).abs
      positive_slopes << s_y - s_x + dist + 1
      positive_slopes << s_y - s_x - dist - 1
      negative_slopes << s_y + s_x + dist + 1
      negative_slopes << s_y + s_x - dist - 1
    end
    positive_slopes.each do |p_slope|
      negative_slopes.each do |n_slope|
        x, y = intersect_slopes(1, -1, p_slope, n_slope)
        next unless x % 1 == 0 && y % 1 == 0 # not integer
        next unless x >= 0 && x <= MAX && y >= 0 && y <= MAX # not in the area
        return [x, y] if !in_sensors_range?(x, y)
      end
    end
  end

  private def intersect_slopes(m1, m2, b1, b2)
    x = (b2 - b1)/(m1 - m2)
    y = (m1*b2 - m2*b1)/(m1 - m2)
    [x, y]
  end

  private def in_sensors_range?(x, y)
    @sensors.any? do |s_x, s_y, b_x, b_y|
      dist_b = (s_x - b_x).abs + (s_y - b_y).abs
      dist = (s_x - x).abs + (s_y - y).abs
      dist_b >= dist
    end
  end

  private def merge(range, r_start, r_end)
    i = range.find_index { |x| x >= r_start }
    j = range.rindex { |x| x <= r_end }
    if !i
      range << r_start
      range << r_end
    elsif !j
      range.insert(0, r_end)
      range.insert(0, r_start)
    elsif j < i
      if i % 2 == 0
        range.insert(j, r_end)
        range.insert(j, r_start)
      end
    elsif i == j
      range[i] = i % 2 == 0 ? r_start : r_end
    else
      range[i] = r_start if i % 2 == 0
      range[j] = r_end if j % 2 != 0
      slice_i = i % 2 == 0 ? i + 1 : i
      slice_j = j % 2 != 0 ? j - 1 : j
      range.slice!(slice_i..slice_j)
    end
  end

end

