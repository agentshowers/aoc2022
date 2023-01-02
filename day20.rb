class Day20
  INPUT = "day20.input"

  def initialize
    @zero = nil
    lines = File.readlines(INPUT, chomp: true)
    @code = lines.map do |x|
      node = Node.new(x.to_i)
      @zero = node if x.to_i == 0
      node
    end
  end

  def one
    reset_buckets
    solve(1, 1)
  end

  def two
    reset_buckets
    solve(10, 811589153)
  end

  private def solve(n, key)
    size = @code.length
    (1..n).each do
      @code.each do |node|
        idx = @bucket_list.index(node)
        move_count = (node.x * key) % (size - 1)
        new_idx = (idx + move_count) % (size - 1)
        @bucket_list.shift(node, idx, new_idx)
      end
    end
    zero_idx = @bucket_list.index(@zero)
    [1000, 2000, 3000].map do |i|
      @bucket_list.get((zero_idx + i) % size).x
    end.sum * key
  end

  private def reset_buckets
    @bucket_list = BucketList.new(@code.length)
    @code.each_with_index do |node, i|
      b = i / BucketList::SIZE
      @bucket_list.buckets[b] << node
      node.bucket = b
    end
  end
end

class BucketList
  SIZE = 250

  attr_accessor :buckets

  def initialize(n)
    n_buckets = (1.0 * n / SIZE).ceil
    @buckets = Array.new(n_buckets) { [] }
  end

  def index(node)
    node.bucket * SIZE + buckets[node.bucket].index(node)
  end

  def get(index)
    bucket = index / SIZE
    @buckets[bucket][index % SIZE]
  end

  def shift(node, from, to)
    if to > from
      dir, grab, place = [1, 0, SIZE-1]
    else
      dir, grab, place = [-1, SIZE-1, 0]
    end

    orig = from / SIZE
    dest = to / SIZE
    @buckets[orig].delete_at(from % SIZE)
    while orig != dest
      shifted_node = @buckets[orig + dir][grab]
      shifted_node.bucket = orig
      @buckets[orig + dir].delete_at(grab)
      @buckets[orig].insert(place, shifted_node)
      orig += dir
    end
    @buckets[orig].insert(to % SIZE, node)
    node.bucket = orig
  end

end

class Node
  attr_reader :x
  attr_accessor :bucket

  def initialize(x)
    @x = x
    @bucket = 0
  end
end