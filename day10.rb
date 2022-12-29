class Day10
  INPUT = "day10.input"
  ALPHABET = {
    422148690 => "A",               
    959335004 => "B",               
    422068812 => "C",               
    959007324 => "D",               
    1024344606 => "E",              
    1024344592 => "F",
    422074958 => "G",
    623856210 => "H",
    948183324 => "I",
    203491916 => "J",
    625758866 => "K",
    554189342 => "L",
    636439122 => "M",
    632117970 => "N",
    422136396 => "O",
    959017488 => "P",
    422136194 => "Q",
    959017618 => "R",
    421794380 => "S",
    474091652 => "T",
    623462988 => "U",
    623462796 => "V",
    623475666 => "W",
    623260242 => "X",
    692723976 => "Y",
    1008869918 => "Z"
  }

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
    text = []
    (0..7).each do |l|
      letter = []
      (0..5).each do |i|
        (0..4).each do |j|
          pos = (l * 5) + (i * 40) + j
          letter << (@crt[pos] == "#" ? 1 : 0)
        end
      end
      text << ALPHABET[letter.join.to_i(2)]
    end
    text.join
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
