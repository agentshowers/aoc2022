class Day21
  INPUT = "day21.input"
  ROOT = "root"
  HUMAN = "humn"

  def initialize
    @monkeys = {}
    File.readlines(INPUT, chomp: true).each do |line|
      key, val = line.split(": ")
      if val =~ /(\w*) ([\+\*\/\-]) (\w*)/
        @monkeys[key] = [$2, $1, $3]
      else
        @monkeys[key] = val.to_i
      end
    end
  end

  def one
    solve(ROOT)
  end

  def two
    left_path = path_to_human(@monkeys[ROOT][1])
    right_path = path_to_human(@monkeys[ROOT][2])
    if left_path.is_a?(Integer)
      solve_equation(right_path, left_path)
    else
      solve_equation(left_path, right_path)
    end
  end

  private def solve(key)
    return @monkeys[key] if @monkeys[key].is_a?(Integer)

    op, left, right = @monkeys[key]
    left_val = solve(left)
    right_val = solve(right)
    left_val.send(op, right_val)
  end

  private def solve_equation(equation, value)
    return value if equation == HUMAN
    op, left, right = equation
    if op == "+"
      if left.is_a?(Integer)
        solve_equation(right, value - left)
      else
        solve_equation(left, value - right)
      end
    elsif op == "-"
      if left.is_a?(Integer)
        solve_equation(right, left - value)
      else
        solve_equation(left, right + value)
      end
    elsif op == "/"
      if left.is_a?(Integer)
        solve_equation(right, left / value)
      else
        solve_equation(left, right * value)
      end
    else
      if left.is_a?(Integer)
        solve_equation(right, value / left)
      else
        solve_equation(left, value / right)
      end
    end
  end

  private def path_to_human(key)
    return HUMAN if key == HUMAN
    return @monkeys[key] if @monkeys[key].is_a?(Integer)

    op, left, right = @monkeys[key]
    left_val = path_to_human(left)
    right_val = path_to_human(right)
    if left_val.is_a?(Integer) && right_val.is_a?(Integer)
      left_val.send(op, right_val)
    else
      [op, left_val, right_val]
    end
  end

end
