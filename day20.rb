class Day20
  INPUT = "day20.input"

  def one
    @map = build_map
    solve(1, 1)
  end

  def two
    @map = build_map
    solve(10, 811589153)
  end

  private def build_map
    map = []
    prev = nil
    File.readlines(INPUT, chomp: true).each do |line|
      node = Node.new(line.to_i)
      node.prev = prev
      prev.next = node if prev
      prev = node
      map << node
    end
    map.last.next = map.first
    map.first.prev = map.last
    map
  end

  private def solve(n, key)
    zero_idx = nil
    (1..n).each do
      @map.each_with_index do |node, i|
        move_count = (node.x * key).abs % (@map.length - 1)
        if node.x == 0
          zero_idx = i
        else
          curr = node.next
          prev = node.prev
          prev.next = curr
          curr.prev = prev
          (1..move_count).each do
            curr = node.x > 0 ? curr.next : curr.prev
          end
          curr.prev.next = node
          node.prev = curr.prev
          node.next = curr
          curr.prev = node
        end
      end
    end
    sum = 0
    i = 0
    node = @map[zero_idx]
    while i <= 3000
      sum += node.x * key if [1000, 2000, 3000].include?(i)
      node = node.next
      i += 1
    end
    sum
  end

end

class Node
  attr_accessor :x, :next, :prev

  def initialize(x)
    @x = x
  end
end