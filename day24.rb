class Day24
  INPUT = "day24.input"

  def initialize
    lines = File.readlines(INPUT, chomp: true)
    @width = lines[0].length - 2
    @right_mask = (1 << (@width - 1))
    @left_mask = @right_mask - 1
    @max = 2.pow(@width)-1

    @up = lines.map { |l| l[1..-2].gsub("^","0").gsub(/[^0]/,"1").to_i(2) }
    @down = lines.map { |l| l[1..-2].gsub("v","0").gsub(/[^0]/,"1").to_i(2) }
    @left = lines.map { |l| l[1..-2].gsub("<","0").gsub(/[^0]/,"1").to_i(2) }
    @right = lines.map { |l| l[1..-2].gsub(">","0").gsub(/[^0]/,"1").to_i(2) }

    @walls = Array.new(@up.length, @max)
    @walls[0] = 2.pow(@width - 1)
    @walls[@up.length-1] = 1
  end

  def one
    @first_trip = solve(0, start_position) do |grid|
      grid.last == 1
    end
    @first_trip
  end

  def two
    second_trip = solve(@first_trip, end_position) do |grid|
      grid.first == 2.pow(@width - 1)
    end
    third_trip = solve(second_trip, start_position) do |grid|
      grid.last == 1
    end
    third_trip
  end

  private def solve(time, position)
    while !yield(position)
      @up = [@max] + @up[1..-2].rotate(1) + [@max]
      @down = [@max] + @down[1..-2].rotate(-1) + [@max]
      @left = @left.map { |r| ((r & @left_mask) << 1) | (r >> (@width - 1)) }
      @right = @right.map { |r| (r >> 1) | (r << (@width - 1)) & @right_mask }
      new_grid = Array.new(position.length)
      position.each_with_index do |r, i|
        r = r | (r << 1) | (r >> 1)
        r = r | position[i-1] if i > 0
        r = r | position[i+1] if i < position.length - 1
        r = r & @up[i] & @down[i] & @left[i] & @right[i] & @walls[i]
        new_grid[i] = r
      end
      position = new_grid
      time +=1
    end
    time
  end

  private def start_position
    grid = Array.new(@up.length, 0)
    grid[0] = 2.pow(@width - 1)
    grid
  end

  private def end_position
    grid = Array.new(@up.length, 0)
    grid[-1] = 1
    grid
  end

end
