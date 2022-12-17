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
    # flow, _ = best_move("AA", 30, good_valves.keys, {})
    # flow
    solve
  end

  def two
    bound("AA", 30, good_valves.keys)
    # elephant = "AA"
    # me = "AA"
    # mins_left_elephant = 26
    # mins_left_me = 26
    # unopened = good_valves.keys
    # total_flow = 0
    # loop do
    #   if mins_left_elephant >= mins_left_me
    #     elephant, mins_left_elephant, flow = move(elephant, mins_left_elephant, unopened)
    #     puts "Moved elephant to #{elephant} (#{mins_left_elephant} left)"
    #   else
    #     me, mins_left_me, flow = move(me, mins_left_me, unopened)
    #     puts "Moved me to #{me} (#{mins_left_me} left)"
    #   end
    #   total_flow += flow
    #   break if mins_left_elephant == 0 && mins_left_me == 0
    # end
    # total_flow
  end

  private def solve
    global_max = 0
    candidates = [["AA", 30, good_valves.keys, 0]]
    while candidates.length > 0
      valve, minutes_left, unopened, curr_flow = candidates.shift
      unopened.each do |v|
        dist = @map[valve][v]
        potential_max = bound(v, minutes_left - dist - 1, unopened - [v])
        if curr_flow + potential_max > global_max
          local_flow = @valves[v][0] * (minutes_left - dist - 1)
          candidates << [v, minutes_left - dist - 1, unopened - [v], curr_flow + local_flow]
        end
      end
    end
    global_max
  end

  private def bound(location, minutes_left, unopened)
    return 0 if minutes_left < 2
    min_dist = unopened.map { |v| @map[v].map { |x| x[1] }.min }.min
    max_flow = unopened.map { |v| @valves[v][0] }.max

    flow = @valves[location][0] * (minutes_left - 1)
    loop do
      minutes_left -= min_dist + 1
      break if minutes_left <= 0
      flow += max_flow * minutes_left
    end
    flow
  end

  private def move(location, minutes_left, unopened)
    _, path = best_move(location, minutes_left, unopened, {})
    if path.length > 0
      minutes_left = minutes_left - @map[location][path.first] - 1
      location = path.first
      flow = @valves[location][0] * minutes_left
      unopened.delete(location)
    else
      minutes_left = 0
      flow = 0
    end
    [location, minutes_left, flow]
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
      if flow > 0
        f, p = best_move(v, minutes_left - dist - 1, unopened - [v], memo)
        total_flow = flow + f
        if total_flow > max_flow
          max_flow = total_flow
          path = [v] + p
        end
      end
    end

    memo[key] = [max_flow, path]
    [max_flow, path]
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

  private def good_valves
    @valves.select { |k, v| v[0] > 0 }
  end

end