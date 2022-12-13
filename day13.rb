
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
    unordered = []
    @packets.each do |x,y|
      unordered << x
      unordered << y
    end
    unordered << [[2]]
    unordered << [[6]]
    quick_sort(unordered, 0, unordered.length - 1)
    count = 1
    unordered.each_with_index do |p, i|
      count *= i+1 if p == [[2]] || p == [[6]]
    end
    count
  end

  private def quick_sort(packets, start, finish)
    if start < finish
      pi = partition(packets, start, finish)
      quick_sort(packets, start, pi - 1)
      quick_sort(packets, pi + 1, finish)
    end
  end

  private def swap(packets, i, j)
    temp = packets[i]
    packets[i] = packets[j]
    packets[j] = temp
  end

  private def partition(packets, start, finish)
    pivot = packets[finish]
    i = start - 1
    j = start
    while j < finish
      if order(packets[j], pivot) == -1
        i += 1
        swap(packets, i, j)
      end
      j += 1
    end
    swap(packets, i + 1, finish)
    i + 1
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
