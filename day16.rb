class Day16
  INPUT = "day16.input"

  def initialize
    @valves = {}
    File.readlines(INPUT, chomp: true).each do |line|
      line =~ /Valve (\w+) has flow rate=(\d+); tunnels? leads? to valves? (.*)/
      @valves[$1] = [$2.to_i, $3.split(", ")]
    end
    @memo = {}
    @map = {}
    build_map("AA")
    good_valves.keys.each { |v| build_map(v) }
  end

  def one
    # return 1915
    solve("AA", 30, 0)
  end

  def two
    # return 2772
    max = 0
    splits = generate_splits(0, 0)
    splits.each_with_index do |unopened, i|
      elephant = solve("AA", 26, unopened)
      me = solve("AA", 26, 2.pow(15)-1 ^ unopened)
      max = [elephant + me, max].max
    end
    max
  end

  private def build_map(valve)
    @map[valve] = {}
    dist = { valve => 0 }
    visited = { valve => true}
    queue = [valve]

    while queue.length > 0
      v = queue.shift
      @valves[v][1].each do |next_v|
        next if visited[next_v]
        dist[next_v] = dist[v] + 1
        @map[valve][next_v] = dist[next_v] if @valves[next_v][0] > 0
        visited[next_v] = true
        queue << next_v
      end
    end
  end

  private def good_valves
    @good_valves ||= @valves.select { |k, v| v[0] > 0 }
  end

  private def solve(valve, minutes_left, unopened)
    key = build_key(valve, minutes_left, unopened)
    return @memo[key] if @memo[key]
  
    max_flow = 0
    good_valves.keys.each_with_index do |v, i|
      next if unopened & (2.pow(i)) > 0
      next unless can_move?(valve, v, minutes_left)
      flow, new_mins_left = move(valve, v, minutes_left)
      total_flow = flow + solve(v, new_mins_left, unopened | 2.pow(i))
      max_flow = [max_flow, total_flow].max
    end

    @memo[key] = max_flow
    max_flow
  end

  private def can_move?(valve, dest, minutes_left)
    minutes_left - @map[valve][dest] - 1 >= 2
  end

  private def move(valve, dest, minutes_left)
    minutes_left -= @map[valve][dest] + 1
    flow = @valves[dest][0] * minutes_left
    [flow, minutes_left]
  end

  private def build_key(valve, minutes_left, unopened)
    base = unopened*10000 + minutes_left*100
    base + (valve == "AA" ? good_valves.keys.length : good_valves.keys.index(valve))
  end


  private def generate_splits(idx, opened)
    len = @good_valves.keys.length
    return [0] if opened > (len / 2)
    return [2.pow(len-idx) - 1] if idx - opened > (len / 2)
    return [0] if idx == len - 1

    open_splits = generate_splits(idx+1, opened+1).map { |s| s*2 + 1 }
    closed_splits = generate_splits(idx+1, opened).map { |s| s*2 }
    open_splits + closed_splits
  end

end