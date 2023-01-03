class Day11
  INPUT = "day11.input"

  def initialize
    @monkeys = []

    File.readlines(INPUT, chomp: true).each_slice(7) do |slice|
      monkey = []
      monkey <<  slice[1].split(": ")[1].split(", ").map(&:to_i)
      slice[2] =~ /Operation: new = old (\+|\*) (old|\d+)/
      monkey << $1
      monkey << ($2 == "old" ? 0 : $2.to_i)
      slice[3] =~ /Test: divisible by (\d+)/
      monkey << $1.to_i
      slice[4] =~ /If true: throw to monkey (\d+)/
      monkey << $1.to_i
      slice[5] =~ /If false: throw to monkey (\d+)/
      monkey << $1.to_i
      @monkeys << monkey
    end
  end

  def one
    run(20) do |item|
      item / 3
    end
  end
  
  def two
    div = @monkeys.map { |m| m[3] }.inject(:*)
    run(10000) do |item|
      item % div
    end
  end

  private def run(rounds)
    activity = Array.new(@monkeys.length, 0)
    items = @monkeys.map{ |m| m[0].dup }
  
    (1..rounds).each do
      @monkeys.each_with_index do |(_, op, op_r, tst, t, f), i|
        activity[i] += items[i].length
        items[i].each do |item|
          right = op_r + (1 - (op_r <=> 0)) * item
          item = item.send(op, right)
          item = yield(item)
          if item % tst == 0
            items[t] << item
          else
            items[f] << item
          end
        end
        items[i] = []
      end
    end

    activity.sort.reverse[..1].inject(:*)
  end
end

