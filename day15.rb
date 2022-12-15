class Day15
  INPUT = "day15.input"
  #LINE = 10
  LINE = 2000000
  #MAX = 20
  MAX = 4000000

  def initialize
    @range_one = []
    @beacons_one = []
    @ranges = Array.new(MAX+1)

    File.readlines(INPUT, chomp: true).each do |line|
      line =~ /Sensor at x=(\-?\d+), y=(\-?\d+): closest beacon is at x=(\-?\d+), y=(\-?\d+)/
      add_range($1.to_i, $2.to_i, $3.to_i, $4.to_i)
    end
  end

  def one
    @range_one.first[1] - @range_one.first[0] + 1 - @beacons_one.uniq.count
  end

  def two
    @ranges.each_with_index do |r, i|
      if r.length > 1
        x = r[0][1] + 1
        return (x * 4000000) + i
      end
    end
  end

  private def add_range(s_x, s_y, b_x, b_y)
    dist = (s_x - b_x).abs + (s_y - b_y).abs
    min_y = [s_y-dist, 0].max
    max_y = [s_y+dist, MAX].min
    (min_y..max_y).each do |i|
      diff = dist - (s_y - i).abs
      @ranges[i] = merge(@ranges[i], s_x - diff, s_x + diff)
      @range_one = merge(@range_one, s_x - diff, s_x + diff, false) if i == LINE
      @beacons_one << b_x if b_y == LINE
    end
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