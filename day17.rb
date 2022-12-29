class Day17

  class VerticalLine
    def self.height
      4
    end
  
    def self.place(tower, x, y)
      (y..y+3).each { |j| tower[j][x] = "#" }
    end
  
    def self.can_move_left?(tower, x, y)
      return false if x == 0
      (y..y+3).none? { |j| tower[j][x-1] == "#" }
    end

    def self.can_move_right?(tower, x, y)
      return false if x == 6
      (y..y+3).none? { |j| tower[j][x+1] == "#" }
    end
  
    def self.can_drop?(tower, x, y)
      y > 0 && tower[y-1][x] == "."
    end
  end

  class HorizontalLine
    def self.height
      1
    end

    def self.place(tower, x, y)
      (x..x+3).each { |i| tower[y][i] = "#" }
    end
  
    def self.can_move_left?(tower, x, y)
      x > 0 && tower[y][x-1] == "."
    end

    def self.can_move_right?(tower, x, y)
      x < 3 && tower[y][x+4] == "."
    end
  
    def self.can_drop?(tower, x, y)
      return false if y == 0
      (x..x+3).none? { |i| tower[y-1][i] == "#" }
    end
  end

  class Cross
    def self.height
      3
    end

    def self.place(tower, x, y)
      tower[y][x+1] = "#"
      (x..x+2).each { |i| tower[y+1][i] = "#" }
      tower[y+2][x+1] = "#"
    end
  
    def self.can_move_left?(tower, x, y)
      x > 0 && tower[y][x] == "." && tower[y+1][x-1] == "." && tower[y+2][x] == "."
    end

    def self.can_move_right?(tower, x, y)
      x < 4 && tower[y][x+2] == "." && tower[y+1][x+3] == "." && tower[y+2][x+2] == "."
    end
  
    def self.can_drop?(tower, x, y)
      y > 0 && tower[y][x] == "." && tower[y-1][x+1] == "." && tower[y][x+2] == "."
    end
  end

  class L
    def self.height
      3
    end

    def self.place(tower, x, y)
      (x..x+2).each { |i| tower[y][i] = "#" }
      tower[y+1][x+2] = "#"
      tower[y+2][x+2] = "#"
    end
  
    def self.can_move_left?(tower, x, y)
      x > 0 && tower[y][x-1] == "." && tower[y+1][x+1] == "." && tower[y+2][x+1] == "."
    end

    def self.can_move_right?(tower, x, y)
      x < 4 && (y..y+2).none? { |j| tower[j][x+3] == "#" }
    end
  
    def self.can_drop?(tower, x, y)
      y > 0 && (x..x+2).none? { |i| tower[y-1][i] == "#" }
    end
  end

  class Square
    def self.height
      2
    end

    def self.place(tower, x, y)
      tower[y][x+1] = "#"
      tower[y][x] = "#"
      tower[y+1][x+1] = "#"
      tower[y+1][x] = "#"
    end
  
    def self.can_move_left?(tower, x, y)
      x > 0 && tower[y][x-1] == "." && tower[y+1][x-1] == "."
    end

    def self.can_move_right?(tower, x, y)
      x < 5 && tower[y][x+2] == "." && tower[y+1][x+2] == "."
    end
  
    def self.can_drop?(tower, x, y)
      y > 0 && tower[y-1][x] == "." && tower[y-1][x+1] == "."
    end
  end

  INPUT = "day17.input"
  PIECES = [HorizontalLine, Cross, L, VerticalLine, Square]
  P1_ROCKS = 3200

  def initialize
    @moves = File.read(INPUT).strip.split("")
    @tower = Array.new(3)
    (0..2).each { |i| @tower[i] = Array.new(7, ".") }
    @tower_height = 0
    run
  end

  def one
    @results[P1_ROCKS-1]
  end

  def two
    @results[@part_two_rocks-1] + @repeated_growth
  end

  private def run
    rocks = 0
    move_count = 0
    @first_loop = nil
    @part_two_rocks = 1000000000000
    @results = []
    loop do
      piece_class = PIECES[rocks % PIECES.length]
      move_count += drop(piece_class)
      rocks += 1
      @results << @tower_height

      if move_count % @moves.length == 0
        if !@first_loop
          @first_loop = [rocks, @tower_height]
        else
          calculate_growth(rocks)
        end
      end

      break if rocks >= P1_ROCKS && rocks >= @part_two_rocks
    end
  end

  private def calculate_growth(rocks)
    diff = rocks - @first_loop[0]
    growth = @tower_height - @first_loop[1]
    loops = (@part_two_rocks - @first_loop[0]) / diff
    @part_two_rocks = @first_loop[0] + (@part_two_rocks - @first_loop[0]) % diff
    @repeated_growth = loops*growth
  end
  
  private def drop(piece_class)
    new_length = @tower_height + 3 + piece_class.height
    (@tower.length..new_length).each { @tower << Array.new(7, ".") }
    x = 2
    y = @tower_height + 3
    moves = 0
    loop do
      next_move = @moves.shift
      x -= 1 if next_move == "<" && piece_class.can_move_left?(@tower, x, y)
      x += 1 if next_move == ">" && piece_class.can_move_right?(@tower, x, y)
      @moves << next_move
      moves += 1
      if piece_class.can_drop?(@tower, x, y)
        y -= 1
      else
        piece_class.place(@tower, x, y)
        @tower_height = [@tower_height, y + piece_class.height].max
        break
      end
    end
    moves
  end

end


