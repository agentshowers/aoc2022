class Day23
  INPUT = "day23.input"
  BUFFER = 20
  MAX = 200

  def initialize
    @map = Array.new(MAX, 0)
    @candidates = {}
    @total_elves = 0
    File.readlines(INPUT, chomp: true).each_with_index do |line, j|
      line.split("").each_with_index do |s, i|
        if s == "#"
          @map[j+BUFFER] += 2 ** (i + BUFFER)
          @total_elves += 1
        end
      end
    end
    rounds
  end

  def one
    @p1
  end

  def two
    @p2
  end

  private def rounds
    directions = ["N", "S", "W", "E"]
    i = 0
    loop do
      if i == 10
        min_x, max_x, min_y, max_y = boundaries
        @p1 = (max_x - min_x + 1) * (max_y - min_y + 1) - @total_elves
      end
      if round(directions)
        @p2 = i + 1
        break
      end
      directions.rotate!(1)
      i += 1
    end
  end

  private def round(directions)
    stable = true
    proposals = Array.new(MAX, 0)
    
    (0..@map.length-1).each do |i|
      stable = move_row(i, proposals, directions) && stable
    end

    proposals.each_with_index do |p, i|
      @map[i] = p
    end

    stable
  end

  private def move_row(row_idx, proposals, directions)
    return true if @map[row_idx] == 0

    row_proposal = free_neighbors(
      @map[row_idx],
      [ 
        @map[row_idx-1] >> 1, @map[row_idx-1], @map[row_idx-1] << 1,
        @map[row_idx]   >> 1,                  @map[row_idx]   << 1,
        @map[row_idx+1] >> 1, @map[row_idx+1], @map[row_idx+1] << 1
      ]
    )
    if row_proposal == @map[row_idx]
      proposals[row_idx] = proposals[row_idx] | row_proposal
      return true
    end

    yet_to_move = @map[row_idx] ^ row_proposal
    
    directions.each do |dir|
      case dir
      when "N"
        prop = free_neighbors(yet_to_move, [@map[row_idx-1], @map[row_idx-1] << 1, @map[row_idx-1] >> 1])
        clashes = prop & proposals[row_idx-1]
        if clashes > 0
          proposals[row_idx-2] = proposals[row_idx-2] | clashes
          proposals[row_idx-1] = proposals[row_idx-1] ^ clashes
          row_proposal = row_proposal | clashes
        end
        proposals[row_idx-1] = proposals[row_idx-1] | (prop ^ clashes)
      when "S"
        prop = free_neighbors(yet_to_move, [@map[row_idx+1], @map[row_idx+1] << 1, @map[row_idx+1] >> 1])
        proposals[row_idx+1] = proposals[row_idx+1] | prop
      when "W"
        prop = free_neighbors(yet_to_move, [@map[row_idx-1] << 1, @map[row_idx] << 1, @map[row_idx+1] << 1])
        clashes = (prop >> 1) & row_proposal
        if clashes > 0
          row_proposal = row_proposal ^ clashes | (clashes << 1) | (clashes >> 1)
        end
        row_proposal = row_proposal | ((prop ^ (clashes << 1)) >> 1)
      when "E"
        prop = free_neighbors(yet_to_move, [@map[row_idx-1] >> 1, @map[row_idx] >> 1, @map[row_idx+1] >> 1])
        clashes = (prop << 1) & row_proposal
        if clashes > 0
          row_proposal = row_proposal ^ clashes | (clashes << 1) | (clashes >> 1)
        end
        row_proposal = row_proposal | ((prop ^ (clashes >> 1)) << 1)
      end
      yet_to_move = yet_to_move ^ prop
    end

    proposals[row_idx] = proposals[row_idx] | row_proposal | yet_to_move
    row_proposal == @map[row_idx]
  end

  private def free_neighbors(row, adjacent)
    occupied = row & adjacent.inject(0, :|)
    row ^ occupied
  end

  private def boundaries
    min_x, max_x, min_y, max_y = [MAX, 0, MAX, 0]
    @map.each_with_index do |row, i|
      if row > 0
        row_max_x = Math.log2(row).floor
        row_min_x = 0
        while row % 2 == 0
          row = row / 2
          row_min_x += 1
        end
        min_x = [row_min_x, min_x].min
        max_x = [row_max_x, max_x].max
        min_y = [i, min_y].min
        max_y = [i, max_y].max
      end
    end
    [min_x, max_x, min_y, max_y]
  end

  def print
    puts boundaries.to_s
    @map.each do |l|
      puts l.to_s(2).rjust(MAX, '0').reverse.gsub("0", ".").gsub("1", "#")
    end
  end
  
end
