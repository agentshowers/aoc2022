class Day10
  INPUT = "day10.input"

  def initialize
    @instructions = File.readlines(INPUT, chomp: true).map do |line|
      inst, val = line.split(" ")
      [inst, val.to_i]
    end
    calculate
  end

  def one
    @sum
  end

  def two
    "\n" + @crt.each_slice(40).map{ |s| s.join }.join("\n")
  end

  private def calculate
    @sum = 0
    @crt = Array.new(240, " ")
    x = 1
    curr = 0

    @instructions.each do |inst|
      cycles = inst[0] == "noop" ? 1 : 2
      (1..cycles).each do
        curr += 1
        @crt[curr-1] = "#" if (x-1..x+1).to_a.select{ |y| y >=0 }.map{|y| y % 40}.include?((curr-1) % 40)
        @sum += (x * curr) if (curr + 20) % 40 == 0
      end
      x += inst[1] if inst[0] != "noop"
    end
    
  end
end
