class Day8
  INPUT = "day08.input"

  attr_reader :n, :m
  
  def initialize
    @trees = File.readlines(INPUT, chomp: true).map do |line|
      line.chars.map(&:to_i)
    end
    @n = @trees.length
    @m = @trees[0].length
    calculate
  end

  def one
    @visible.map { |row| row.count { |v| v } }.sum
  end

  def two
    @views.map(&:max).max 
  end

  def calculate
    @views = Array.new(n) 
    (1..n).each { |i| @views[i-1] = Array.new(m, 1) }
    @visible = Array.new(n) 
    (1..n).each { |i| @visible[i-1] = Array.new(m, false) }

    (0..n-1).each do |i|
      iterate(i, 0, 0, 1)
      iterate(i, m-1, 0, -1)
    end
    (0..m-1).each do |j|
      iterate(0, j, 1, 0)
      iterate(n-1, j, -1, 0)
    end
  end

  def iterate(i, j, dir_i, dir_j)
     stack = []
     while i >= 0 && i < n && j >= 0 && j < m
       val = @trees[i][j]
       loop do
         if stack.length == 0
           @views[i][j] *= i if dir_i == 1
           @views[i][j] *= (n - i - 1) if dir_i == -1
           @views[i][j] *= j if dir_j == 1
           @views[i][j] *= (m - j - 1) if dir_j == -1
           @visible[i][j] = true
           break
         else
           stack_val = @trees[stack.last[0]][stack.last[1]]
           if val > stack_val
             stack.pop
           else
             diff = (i - stack.last[0] + j - stack.last[1]).abs
             @views[i][j] *= diff
             break
           end
         end
       end
       stack << [i, j]
       i += dir_i
       j += dir_j
     end
  end
end
