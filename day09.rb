class Day9
  INPUT = "day09.input"

  def initialize
    @moves = File.readlines(INPUT, chomp: true).map do |line|
      dir, val = line.split(" ")
      [dir, val.to_i]
    end
  end

  def one
    move_snake(2)
  end
  
  def two
    move_snake(10)
  end

  private def move(snake, dir)
    case dir
    when "U"
      snake[0][1] += 1
    when "D"
      snake[0][1] += -1
    when "L"
      snake[0][0] += -1
    when "R"
      snake[0][0] += 1
    end
  end
  
  private def follow(snake, lead, follow)
    x_diff = snake[lead][0] - snake[follow][0]
    y_diff = snake[lead][1] - snake[follow][1]
    if x_diff.abs > 1 || y_diff.abs > 1
      snake[follow][0] += x_diff <=> 0
      snake[follow][1] += y_diff <=> 0
    end
  end
  
  private def move_snake(size)
    positions = {}
    snake = Array.new(size)
    (0..size-1).each { |i| snake[i] = [0, 0]}
    positions["0,0"] = true
  
    @moves.each do |dir, val|
      while val > 0
        move(snake, dir)
        (1..size-1).each do |i|
          follow(snake, i-1, i)
        end
        positions["#{snake[size-1][0]},#{snake[size-1][1]}"] = true
        val -= 1
      end
    end
    
    positions.count
  end
end
