class Day6
  INPUT = "day06.input"
  EXAMPLE = "mjqjpqmgbljsphdztnvjfqwrcgsmlb"

  def initialize
    @text = File.read(INPUT)
  end

  def one
    run(4)
  end

  def two
    run(14)
  end

  def run(n)
    count = {} 

    i = 0
    while i < @text.length 
      c = @text[i]
      count[c] = (count[c] || 0) + 1
      if i >= n
        prev_c = @text[i-n]
        count[prev_c] -= 1
        count.delete(prev_c) if count[prev_c] == 0
        return i+1 if count.keys.length == n
      end
      i += 1
    end
  end
end
