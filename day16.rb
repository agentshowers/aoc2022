class Day16
  INPUT = "day16.input"

  def initialize
    @valves = {}
    File.readlines(INPUT, chomp: true).each do |line|
      line =~ /Valve (\w+) has flow rate=(\d+); tunnels? leads? to valves? (.*)/
      @valves[$1] = [$2.to_i, $3.split(", ")]
    end
    @map = {}
    @valves.each do |k,v|
      build_map(k) if v[0] > 0 || k == "AA"
    end
  end

  def one
    best_move("AA", 30, good_valves.keys, {})
  end

  def two
    best_move2("AA", 26, "AA", 26, good_valves.keys, {}, true)
  end

  private def build_map(valve)
    @map[valve] = {}
    dist = {}
    visited = {}

    queue = [valve]
    dist[valve] = 0
    visited[valve] = true

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

  private def best_move(valve, minutes_left, unopened, memo)
    key = "#{valve}-#{minutes_left}-#{unopened.sort.join(',')}"
    return memo[key] if memo[key]
  
    max_flow = 0
    unopened.each do |v|
      dist = @map[valve][v]
      flow = @valves[v][0] * (minutes_left - dist - 1)
      total_flow = flow > 0 ? flow + best_move(v, minutes_left - dist - 1, unopened - [v], memo) : 0
      max_flow = [max_flow, total_flow].max
    end
    
    memo[key] = max_flow
    max_flow
  end

  private def best_move2(valve_e, minutes_left_e, valve_m, minutes_left_m, unopened, memo)
    key = "#{valve_e}-#{minutes_left_e}-#{valve_m}-#{minutes_left_m}-#{unopened.sort.join(',')}"
    return memo[key] if memo[key]
  
    max_flow = 0
    unopened.each do |v|
      dist = @map[valve_m][v]
      flow = @valves[v][0] * (minutes_left_m - dist - 1)
      move_me = flow > 0 ? flow + best_move2(valve_e, minutes_left_e, v, minutes_left_m - dist - 1, unopened - [v], memo) : 0

      dist = @map[valve_e][v]
      flow = @valves[v][0] * (minutes_left_e - dist - 1)
      move_elephant = flow > 0 ? flow + best_move2(v, minutes_left_e - dist - 1, valve_m, minutes_left_m, unopened - [v], memo) : 0

      max_flow = [max_flow, move_me, move_elephant].max
    end
    
    memo[key] = max_flow
    max_flow
  end

  private def greedy(valve, minutes_left, unopened)
    max_flow = 0
    next_valve = nil
    left = 0
    unopened.each do |v|
      dist = @map[valve][v]
      flow = @valves[v][0] * (minutes_left - dist - 1)
      if flow > max_flow
        max_flow = flow
        next_valve = v
        left = minutes_left - dist - 1
      end
    end
    [next_valve, max_flow, left]
  end

  private def good_valves
    @valves.select { |k, v| v[0] > 0 }
  end

end