class Day15
  INPUT = "day15.input"
  LINE = 2000000
  MAX = 4000000

  def initialize
    @beacon_free = []
    @map = {}
    (0..MAX-1).each do |i|
      (0..MAX-1).each { |j| @map["#{i},#{j}"] = true }
    end
    File.readlines(INPUT, chomp: true).each do |line|
      line =~ /Sensor at x=(\-?\d+), y=(\-?\d+): closest beacon is at x=(\-?\d+), y=(\-?\d+)/
      puts "doing sensonr #{$1} #{$2}"
      find_free($1.to_i, $2.to_i, $3.to_i, $4.to_i)
      fill_map($1.to_i, $2.to_i, $3.to_i, $4.to_i)
    end
  end

  def one
    # should be 6124805
    @beacon_free.uniq.count
  end

  def two
    @map
  end

  private def find_free(s_x, s_y, b_x, b_y)
    dist = (s_x - b_x).abs + (s_y - b_y).abs
    cur = (LINE - s_y).abs
    @beacon_free << s_x if cur > 0
    i = 1
    while cur + i <= dist
      @beacon_free << s_x + i if s_x + i != b_x
      @beacon_free << s_x - i if s_x - i != b_x
      i += 1
    end
  end

  private def fill_map(s_x, s_y, b_x, b_y)
    delete(s_x, s_y)
    dist = (s_x - b_x).abs + (s_y - b_y).abs
    min_x = [s_x-dist, 0].max
    max_x = [s_x+dist, MAX].min
    (min_x..max_x).each do |i|
      diff = dist - (s_x - i).abs
      min_y = [s_y - diff, 0].max
      max_y = [s_y + diff, MAX].min
      next if min_y > max_y
      (min_y..max_y).each do |j|
        delete(i, j)
      end
    end
  end

  private def delete(i, j)
    @map.delete("#{i},#{j}")
  end
end