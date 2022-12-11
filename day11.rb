class Day11
  INPUT = "day11.input"

  def initialize
    @monkeys = []

    File.readlines(INPUT, chomp: true).each_slice(7) do |slice|
      monkey  = {}
      monkey["items"] = slice[1].split(": ")[1].split(", ").map(&:to_i)
      slice[2] =~ /Operation: new = old (\+|\*) (old|\d+)/
      monkey["operation"] = [$1, $2]
      slice[3] =~ /Test: divisible by (\d+)/
      monkey["test"] = $1.to_i
      slice[4] =~ /If true: throw to monkey (\d+)/
      monkey["true"] = $1.to_i
      slice[5] =~ /If false: throw to monkey (\d+)/
      monkey["false"] = $1.to_i
      @monkeys << monkey
    end
  end

  def one
    run(20) do |item|
      item / 3
    end
  end
  
  def two
    div = @monkeys.map { |m| m["test"] }.inject(:*)
    run(10000) do |item|
      item % div
    end
  end

  private def run(rounds)
    activity = Array.new(@monkeys.length, 0)
    items = @monkeys.map{ |m| m["items"].dup }
  
    (1..rounds).each do
      @monkeys.each_with_index do |monkey, i|
        items[i].each do |item|
          activity[i] += 1
          right = monkey["operation"][1] == "old" ? item : monkey["operation"][1].to_i
          item = item.send(monkey["operation"][0], right)
          item = yield(item)
          if item % monkey["test"] == 0
            items[monkey["true"]] << item
          else
            items[monkey["false"]] << item
          end
        end
        items[i] = []
      end
    end

    activity.sort.reverse[..1].inject(:*)
  end
end

