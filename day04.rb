class Day4
  INPUT = "day04.input"

  def initialize
    pairs = File.readlines(INPUT, chomp: true)
    @assignments = pairs.map do |pair|
      pair.split(",").map do |elf|
        elf.split("-").map(&:to_i)
      end
    end
  end

  def one
    count = 0
    @assignments.each do |ass|
      count += 1 if (ass[0][0] <= ass[1][0] && ass[0][1] >= ass[1][1]) || (ass[0][0] >= ass[1][0] && ass[0][1] <= ass[1][1])
    end
    count
  end

  def two
    count = 0
    @assignments.each do |ass|
      if (ass[0][0] >= ass[1][0] && ass[0][0] <= ass[1][1]) ||
        (ass[0][1] >= ass[1][0] && ass[0][1] <= ass[1][1]) ||
        (ass[1][0] >= ass[0][0] && ass[1][0] <= ass[0][1]) ||
        (ass[1][1] >= ass[0][0] && ass[1][1] <= ass[0][1])
        count += 1 
      end
      
    end
    count
  end
end
