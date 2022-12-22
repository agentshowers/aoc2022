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
    @good_valves = @valves.select { |k, v| v[0] > 0 }
    @good_valves.keys.each { |v| build_map(v) }
    @sorted = @valves.map { |k,v| v[0] }.sort.reverse
    build_map("AA")
  end

  def one
    # return 1915
    solve("AA", 30, 0)
  end

  def two
    #return 2772
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
    visited = { valve => true }
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

  private def solve(valve, minutes_left, unopened)
    @global_best = 0
    inner_solve(valve, minutes_left, unopened, 0)
    @global_best
  end

  private def inner_solve(valve, minutes_left, unopened, current_flow)
    base = unopened*10000 + minutes_left*100
    key = base + (valve == "AA" ? @good_valves.keys.length : @good_valves.keys.index(valve))
    return @memo[key] if @memo[key]
    max_flow = 0

    if ceiling(valve, minutes_left, unopened, current_flow) >= @global_best
      @good_valves.keys.each_with_index do |v, i|
        next if unopened & (2.pow(i)) > 0
        next unless minutes_left - @map[valve][v] - 1 >= 2
      
        new_mins_left = minutes_left - @map[valve][v] - 1
        flow = @valves[v][0] * new_mins_left
        total_flow = flow + inner_solve(v, new_mins_left, unopened | 2.pow(i), current_flow + flow)
        max_flow = [max_flow, total_flow].max
      end
    end

    @global_best = [max_flow, @global_best].max
    @memo[key] = max_flow
    max_flow
  end

  private def ceiling(valve, minutes_left, unopened, current_flow)
    n = minutes_left / 3
    best_flow = @sorted[[10-n, 0].max]
    sum = n*(n+1)/2
    current_flow + sum * best_flow * 3 + best_flow * (minutes_left % 3)
  end

  # The minimum distance between "good" valves is 2.
  # Including the minute it takes to open the valve,
  # the elephant or I can open at most 26/3 = 8 valves.
  # So we only care about splits where one has 7 and the
  # other has 8 valves to go through.
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