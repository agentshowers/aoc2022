class Day7
  INPUT = "day07.input"
  ROOT = "/"

  def initialize
    lines = File.readlines(INPUT, chomp: true)
    @directories = {}
    @directories[ROOT] = 0
    @total = 0
    cur_dir = ROOT
    lines.each do |line|
      if line =~ /\$ cd (.*)/
        if $1 == ".."
          cur_dir = parents(cur_dir).first
        elsif $1 == "/"
          cur_dir = ROOT
        else
          cur_dir = mv(cur_dir, $1)
        end
      elsif line =~ /(\d+) .*/
        size = $1.to_i
        @directories[cur_dir] = (@directories[cur_dir] || 0) + size
        parents(cur_dir).each do |p|
          @directories[p] = (@directories[p] || 0) + size
        end
        @total += size
      end
    end
  end

  def parents(dir)
    p = []
    loop do
      dir = dir.rpartition("/").first
      if dir == ""
        p << ROOT
        break
      else
        p << dir
      end
    end
    p
  end

  def mv(cur_dir, dest)
    return "/#{dest}" if cur_dir == ROOT
    "#{cur_dir}/#{dest}" 
  end

  def one
    sum = 0
    @directories.each do |_, v|
      sum += v if v < 100000
    end
    sum
  end

  def two
    target = 30000000 - (70000000 - @total)
    min = 700000000
    @directories.each do |_, v|
      min = [v, min].min if v >= target
    end
    min
  end
end
