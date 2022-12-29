class Day25
  INPUT = "day25.input"
  S_TO_I = { "-" => -1, "=" => -2, "0" => 0, "1" => 1, "2" => 2 }
  I_TO_S = [["0", 0], ["1", 0], ["2", 0], ["=", 1], ["-", 1]]

  def initialize
    @snafus = File.readlines(INPUT, chomp: true)
  end

  def one
    total = @snafus.map{ snafu_to_number(_1) }.sum
    number_to_snafu(total)
  end

  def two
    "⭐"
  end

  private def snafu_to_number(snafu)
    snafu.reverse.chars.each_with_index.map do |c, idx|
      S_TO_I[c] * 5.pow(idx)
    end.sum
  end

  private def number_to_snafu(number)
    snafu = []
    while number > 0
      s, carry_over = I_TO_S[number % 5]
      snafu << s
      number = (number / 5) + carry_over
    end
    snafu.reverse.join("")
  end
end