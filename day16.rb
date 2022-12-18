class Day16
  INPUT = "day16.input"

  def initialize
    @valves = {}
    File.readlines(INPUT, chomp: true).each do |line|
      line =~ /Valve (\w+) has flow rate=(\d+); tunnels? leads? to valves? (.*)/
      @valves[$1] = [$2.to_i, $3.split(", ")]
    end
    @map = {}
    build_map("AA")
    good_valves.keys.each { |v| build_map(v) }
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

  def one
    # Answer 1915
    # Example 1651
    solve_single("AA", 30, 0, {})
  end

  private def solve_single(valve, minutes_left, unopened, memo)
    key = build_single_key(valve, minutes_left, unopened)
    return memo[key] if memo[key]
  
    max_flow = 0
    good_valves.keys.each_with_index do |v, i|
      next if unopened & (2.pow(i)) > 0
      next unless can_move?(valve, v, minutes_left)
      flow, new_mins_left = move(valve, v, minutes_left)
      total_flow = flow + solve_single(v, new_mins_left, unopened | 2.pow(i), memo)
      max_flow = [max_flow, total_flow].max
    end

    memo[key] = max_flow
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

  private def build_single_key(valve, minutes_left, unopened)
    base = unopened*10000 + minutes_left*100
    base + (valve == "AA" ? good_valves.keys.length : good_valves.keys.index(valve))
  end

  def two
    # Answer 2772
    # Example 1707
    solve_double("AA", 26, "AA", 26, 0, {}, true)
    #bound("AA", 30, good_valves.keys)
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

  private def solve_double(me, mins_me, elephant, mins_elephant, unopened, memo, log = false)
    key = build_double_key(me, mins_me, elephant, mins_elephant, unopened)
    return memo[key] if memo[key]
  
    max_flow = 0
    good_valves.keys.each_with_index do |vi, i|
      puts "Solving #{vi}" if log
      next if unopened & (2.pow(i)) > 0
      move_me_i = can_move?(me, vi, mins_me)
      move_el_i = can_move?(elephant, vi, mins_elephant)
      next if !move_el_i && !move_me_i

      el_moved = false
      me_moved = false
      j = i + 1
      while j < good_valves.keys.length
        next if unopened & (2.pow(j)) > 0
        vj = good_valves.keys[j]
        move_me_j = can_move?(me, vj, mins_me)
        move_el_j = can_move?(elephant, vj, mins_elephant)
        next if !move_el_j && !move_me_j
        if move_el_i && move_me_j
          flow_el, ml_el = move(elephant, vi, mins_elephant)
          flow_me, ml_me = move(me, vj, mins_me)
          total_flow = flow_me + flow_el
          total_flow += solve_double(vj, ml_me, vi, ml_el, unopened | 2.pow(i) | 2.pow(j), memo)
          max_flow = [max_flow, total_flow].max
          el_moved = true
        end
        if move_el_j && move_me_i
          if me != elephant
            flow_el, ml_el = move(elephant, vj, mins_elephant)
            flow_me, ml_me = move(me, vi, mins_me)
            total_flow = flow_me + flow_el
            total_flow += solve_double(vi, ml_me, vj, ml_el, unopened | 2.pow(i) | 2.pow(j), memo)
            max_flow = [max_flow, total_flow].max
          end
          me_moved = true
        end
        j += 1
      end
      if !el_moved && move_el_i
        flow_el, ml_el = move(elephant, vi, mins_elephant)
        total_flow = flow_el + solve_double(me, mins_me, vi, ml_el, unopened | 2.pow(i), memo)
        max_flow = [max_flow, total_flow].max
      end
      if !me_moved && move_me_i
        flow_me, ml_me = move(me, vi, mins_me)
        total_flow += flow_me + solve_double(vi, ml_me, elephant, mins_elephant, unopened | 2.pow(i), memo)
        max_flow = [max_flow, total_flow].max
      end
    end

    memo[key] = max_flow
    max_flow
  end

  private def build_double_key(v_me, ml_me, v_el, ml_el, unopened)
    key = unopened*100000000 + ml_me*1000000 + ml_el*10000
    key += 100 * (v_me == "AA" ? good_valves.keys.length : good_valves.keys.index(v_me))
    key += (v_el == "AA" ? good_valves.keys.length : good_valves.keys.index(v_el))
    key
  end

  # private def solve
  #   global_max = 0
  #   candidates = [["AA", 30, good_valves.keys, 0]]
  #   while candidates.length > 0
  #     valve, minutes_left, unopened, curr_flow = candidates.shift
  #     unopened.each do |v|
  #       dist = @map[valve][v]
  #       potential_max = bound(v, minutes_left - dist - 1, unopened - [v])
  #       if curr_flow + potential_max > global_max
  #         local_flow = @valves[v][0] * (minutes_left - dist - 1)
  #         candidates << [v, minutes_left - dist - 1, unopened - [v], curr_flow + local_flow]
  #       end
  #     end
  #   end
  #   global_max
  # end

  # private def bound(location, minutes_left, unopened)
  #   return 0 if minutes_left < 2
  #   min_dist = unopened.map { |v| @map[v].map { |x| x[1] }.min }.min
  #   max_flow = unopened.map { |v| @valves[v][0] }.max

  #   flow = @valves[location][0] * (minutes_left - 1)
  #   loop do
  #     minutes_left -= min_dist + 1
  #     break if minutes_left <= 0
  #     flow += max_flow * minutes_left
  #   end
  #   flow
  # end

  # private def move(location, minutes_left, unopened)
  #   _, path = best_move(location, minutes_left, unopened, {})
  #   if path.length > 0
  #     minutes_left = minutes_left - @map[location][path.first] - 1
  #     location = path.first
  #     flow = @valves[location][0] * minutes_left
  #     unopened.delete(location)
  #   else
  #     minutes_left = 0
  #     flow = 0
  #   end
  #   [location, minutes_left, flow]
  # end


  # private def best_move(valve, minutes_left, unopened, memo)
  #   key = "#{valve}-#{minutes_left}-#{unopened.sort.join(',')}"
  #   return memo[key] if memo[key]
  
  #   max_flow = 0
  #   unopened.each do |v|
  #     dist = @map[valve][v]
  #     flow = @valves[v][0] * (minutes_left - dist - 1)
  #     if flow > 0
  #       total_flow = flow + best_move(v, minutes_left - dist - 1, unopened - [v], memo)
  #       max_flow = [max_flow, total_flow].max
  #     end
  #   end

  #   memo[key] = max_flow
  #   max_flow
  # end



  # private def best_move4
  #   queue = [[build_key("AA", 30, 0), 0]]
  #   visited = {}
  #   global_max = 0
  #   while queue.length > 0
  #     key, curr_flow = queue.shift
  #     valve, minutes_left, unopened = read_key(key)
  #     next if visited[key]
  #     visited[key] = true
  #     good_valves.keys.each_with_index do |v, i|
  #       next if unopened & (2.pow(i)) > 0
  #       #puts "#{valve} #{minutes_left} #{key}"
  #       dist = @map[valve][v]
  #       if minutes_left - dist - 1 < 2
  #         global_max = [global_max, curr_flow].max
  #       else
  #         potential_max = bound(v, minutes_left - dist - 1, list_from_int(unopened | 2.pow(i)))
  #         if curr_flow + potential_max > global_max
  #           local_flow = @valves[v][0] * (minutes_left - dist - 1)
  #           queue << [build_key(v, minutes_left - dist - 1, unopened | 2.pow(i)), curr_flow + local_flow]
  #         end
  #       end
  #     end
  #   end
    
  #   global_max
  # end

  # private def list_from_int(unopened)
  #   list = []
  #   good_valves.keys.each_with_index do |v, i|
  #     list << v unless unopened & (2.pow(i)) > 0
  #   end
  #   list 
  # end

  # private def read_key(key)
  #   unopened = key / 10000
  #   minutes_left = (key % 10000) / 100
  #   idx = key % 100
  #   valve = idx == good_valves.keys.length ? "AA" : good_valves.keys[idx]
  #   [valve, minutes_left, unopened]
  # end

  # private def best_move2(valve_e, minutes_left_e, valve_m, minutes_left_m, unopened, memo)
  #   key = "#{valve_e}-#{minutes_left_e}-#{valve_m}-#{minutes_left_m}-#{unopened.sort.join(',')}"
  #   return memo[key] if memo[key]
  
  #   max_flow = 0
  #   unopened.each do |v|
  #     dist = @map[valve_m][v]
  #     flow = @valves[v][0] * (minutes_left_m - dist - 1)
  #     move_me = flow > 0 ? flow + best_move2(valve_e, minutes_left_e, v, minutes_left_m - dist - 1, unopened - [v], memo) : 0

  #     dist = @map[valve_e][v]
  #     flow = @valves[v][0] * (minutes_left_e - dist - 1)
  #     move_elephant = flow > 0 ? flow + best_move2(v, minutes_left_e - dist - 1, valve_m, minutes_left_m, unopened - [v], memo) : 0

  #     max_flow = [max_flow, move_me, move_elephant].max
  #   end
    
  #   memo[key] = max_flow
  #   max_flow
  # end



end