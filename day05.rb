class Day5
  INPUT = "day05.input"

  def initialize
    lines = File.readlines(INPUT)
    n = lines[0].length / 4
    @stacks = Array.new(n)
    @moves = []

    lines.each do |line|
      if line.chars.include?("[")
        i = 0
        while i < n
          char = line[i*4+1]
          if char != " "
            @stacks[i] = [char] + (@stacks[i] || [])
          end
          i += 1
        end
      elsif line =~ /move (\d+) from (\d) to (\d)/
        @moves << [$1.to_i, $2.to_i, $3.to_i]
      end
    end
  end

  def one
    move(false)
  end

  def two
    move(true)
  end

 def move(batch)
    stacks = @stacks.map { |s| s.dup } 
    @moves.each do |n, from, to|
      stack = stacks[from-1]
      size = stack.length
      move_block = stack[size-n..size]
      stack[size-n..] = []
      move_block.reverse! unless batch
      stacks[to-1] += move_block
    end
    stacks.map(&:last).join
 end

end
