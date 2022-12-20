class Day20
  INPUT = "day20.input"

  def initialize
    @zero = nil
    @code = File.read(INPUT).split("\n").map do |x|
      node = Node.new(x.to_i)
      @zero = node if x.to_i == 0
      node
    end
  end

  def one
    solve(1, 1)
  end

  def two
    solve(10, 811589153)
  end

  private def solve(n, key)
    size = @code.length
    list = @code.dup
    (1..n).each do
      @code.each do |node|
        idx = list.index(node)
        move_count = (node.x * key) % (size - 1)
        new_idx = (idx + move_count) % (size - 1)
        list.delete_at(idx)
        list.insert(new_idx, node)
      end
    end
    zero_idx = list.index(@zero)
    sum = list[(zero_idx + 1000) % size].x + list[(zero_idx + 2000) % size].x + list[(zero_idx + 3000) % size].x
    sum * key
  end
end

class Node
  attr_reader :x

  def initialize(x)
    @x = x
  end
end