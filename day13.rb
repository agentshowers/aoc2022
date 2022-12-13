
require 'json'

class Day13
  INPUT = "day13.input"

  def initialize
    @packets = []
    File.readlines(INPUT, chomp: true).each_slice(3) do |slice|
      @packets << [JSON.parse(slice[0]), JSON.parse(slice[1])]
    end
  end

  def one
    count = 0
    @packets.each_with_index do |pair, i|
      count += i+1 if order(pair[0], pair[1]) == -1
    end
    count
  end

  def two
    count_2 = 0
    count_6 = 0

    @packets.each do |x,y|
      count_2 += 1 if order(x, [[2]]) == -1
      count_2 += 1 if order(y, [[2]]) == -1
      count_6 += 1 if order(x, [[6]]) == -1
      count_6 += 1 if order(y, [[6]]) == -1
    end

    (count_2 + 1) * (count_6 + 2)
  end

  private def order(left, right)
    return order(left, [right]) if left.kind_of?(Array) && !right.kind_of?(Array)
    return order([left], right) if !left.kind_of?(Array) && right.kind_of?(Array)
    return left <=> right if !left.kind_of?(Array) && !right.kind_of?(Array)

    i = 0
    while i < left.length
      return 1 if i >= right.length

      comp = order(left[i], right[i])
      return comp if comp != 0

      i += 1
    end
    return 0 if i == right.length
    -1
  end

end
