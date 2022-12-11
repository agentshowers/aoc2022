class Day3
  INPUT = "day03.input"

  def initialize
    @rucksacks = File.readlines(INPUT, chomp: true)
  end

  def one
    total = 0
    @rucksacks.each do |sack|
      seen = {}
      i = 0
      while i < sack.length / 2
        seen[sack[i]] = true
        i += 1
      end
      while i < sack.length
        if seen[sack[i]]
          total += priority(sack[i])
          break
        end
        i += 1
      end
    end
    total
  end

  def two
    total = 0
    @rucksacks.each_slice(3) do |slice|
      seen = {}
      slice.each do |sack|
        sack.chars.uniq.each do |c|
          seen[c] = (seen[c] || 0) + 1
          if seen[c] == 3
            total += priority(c)
            break
          end
        end
      end
    end
    total
  end

  private def priority(c)
    return c.ord - 38 if c.ord <= 90
    
    c.ord - 96
  end
end
