class Day16
  INPUT = "day16.input"

  def initialize
    @valves = {}
    File.readlines(INPUT, chomp: true).each do |line|
      line =~ /Valve (\w+) has flow rate=(\d+); tunnels? leads? to valves? (.*)/
      @valves[$1] = [$2.to_i, $3.split(", ")]
    end
    
    @map = {}
    @useful_valves = @valves.select { |k, v| v[0] > 0 }
    @useful_valves.keys.each { |v| build_map(v) }
    build_map("AA")
  end

  def one
    # return 1915
    @memo = {}
    @global_best = 0
    solve("AA", 30, 0, 0)  
    @global_best
  end

  def two
    #return 2772
    @memo = {}
    @global_best = 0
    @save_best = true
    @best_per_set = {}
    solve("AA", 26, 0, 0)
    sorted = @best_per_set.sort_by { |_, v| -v }
    sorted.map do |k1, v1|
      comp = sorted.find { |k2, _| k1.to_i & k2.to_i == 0 }
      comp ? v1 + comp[1] : 0
    end.max
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

  private def solve(valve, minutes_left, unopened, current_flow)
    base = unopened*10000 + minutes_left*100
    key = base + (valve == "AA" ? @useful_valves.keys.length : @useful_valves.keys.index(valve))
    return @memo[key] if @memo[key]

    max_flow = 0
    best_set = 0
    if @full_solve || ceiling(valve, minutes_left, unopened, current_flow) >= @global_best
      @useful_valves.keys.each_with_index do |v, i|
        next if unopened & (2.pow(i)) > 0
        if minutes_left - @map[valve][v] - 1 >= 2
          new_mins_left = minutes_left - @map[valve][v] - 1
          flow = @valves[v][0] * new_mins_left
          f, u = solve(v, new_mins_left, unopened | 2.pow(i), current_flow + flow)
          total_flow = flow + f 
          if total_flow > max_flow
            max_flow = total_flow
            best_set = u | 2.pow(i)
          end
          @best_per_set[u] = [(@best_per_set[u] || 0), total_flow].max if @save_best
        elsif @save_best
          @best_per_set[unopened] = [(@best_per_set[unopened] || 0), current_flow].max
        end
      end
    end

    @global_best = [max_flow, @global_best].max
    @memo[key] = [max_flow, best_set]
    [max_flow, best_set]
  end

  private def ceiling(valve, minutes_left, unopened, current_flow)
    @sorted ||= @valves.map { |k,v| v[0] }.sort.reverse
    n = minutes_left / 3
    best_flow = @sorted[[10-n, 0].max]
    sum = n*(n+1)/2
    current_flow + sum * best_flow * 3 + best_flow * (minutes_left % 3)
  end

end

