class Day11
  INPUT = "day11.input"

  def initialize
    @monkeys = []
    @initial_items = []

    File.readlines(INPUT, chomp: true).each_slice(7) do |slice|
      @initial_items <<  slice[1].split(": ")[1].split(", ").map(&:to_i)
      monkey = []
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
    activity = Array.new(@monkeys.length, 0)
    items = @initial_items.map{ _1.dup }
  
    (1..20).each do
      @monkeys.each_with_index do |(op, op_r, tst, t, f), i|
        activity[i] += items[i].length
        items[i].each do |item|
          right = op_r == 0 ? item : op_r
          item = op == "*" ? item * right : item + right
          item = item / 3
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
  
  def two
    div = @monkeys.map { |m| m[2] }.inject(:*)

    activity = Array.new(@monkeys.length, 0)
    items = @initial_items.map{ _1.dup }
  
    (1..10000).each do
      @monkeys.each_with_index do |(op, op_r, tst, t, f), i|
        activity[i] += items[i].length
        items[i].each do |item|
          right = op_r == 0 ? item : op_r
          item = op == "*" ? item * right : item + right
          item = item % div
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

