class Day2
  INPUT = "day02.input"

  def initialize
    @strategy = File.readlines(INPUT, chomp: true).map {|l| l.split(" ")}
  end

  def one
    points = 0
    @strategy.each do |s|
    play = (s[1].ord - 23).chr
    result = (play.ord - s[0].ord + 1) % 3
    points += play.ord - 64 + result*3
    end
    points
  end

  def two
    points = 0
    @strategy.each do |s|
    case s[1]
    when "X"
        play = (s[0].ord - 1 == 64 ? 67 : s[0].ord - 1).chr
    when "Y"
        play = s[0]
        points += 3
    when "Z"
        play = (s[0].ord + 1 == 68 ? 65 : s[0].ord + 1).chr
        points += 6
    end
    points += play.ord - 64
    end
    points
  end
end
