class Day19
  INPUT = "day19.input"

  def initialize
    @blueprints = File.readlines(INPUT, chomp: true).map do |line|
      line =~ /Blueprint \d+\: Each ore robot costs (\d+) ore\. Each clay robot costs (\d+) ore\. Each obsidian robot costs (\d+) ore and (\d+) clay\. Each geode robot costs (\d+) ore and (\d+) obsidian\./
      [[$1.to_i, 0, 0, 0],
      [$2.to_i, 0, 0, 0],
      [$3.to_i, $4.to_i, 0, 0],
      [$5.to_i, 0, $6.to_i, 0]]
    end
  end

  def one
    #return 1115
    @max_minutes = 24
    @blueprints.each_with_index.map do |b, i|
      #puts "solving #{i}"
      geodes = solve(b)
      #puts "got #{geodes}"
      geodes * (i+1)
    end.sum
  end

  def two
    #return 25056
    @max_minutes = 32
    product = 1
    @blueprints[0..2].each_with_index.map do |b, i|
      #puts "solving #{i}"
      geodes = solve(b)
      #puts "got #{geodes}"
      product *= geodes
    end.sum
    product
  end

  private def solve(blueprint)
    init_key = build_key(1,0,0,0,1,0,0,0)
    queue = [init_key]
    acc = { init_key => 0 }
    max_g = 0
    @global_floor = 0
    while queue.length > 0
      key = queue.shift
      geode = acc[key]
      minutes, ore, clay, obs, ore_r, clay_r, obs_r, geode_r = read_key(key)
      if ceiling(geode, geode_r, minutes) >= @global_floor
        candidates(ore, clay, obs, ore_r, clay_r, obs_r, geode_r, blueprint, minutes).each do |o,c,ob,g,o_r,c_r,ob_r,g_r,mins|
          g += geode
          if mins > @max_minutes
            max_g = [g, max_g].max
          else
            key = build_key(mins,o,c,ob,o_r,c_r,ob_r,g_r)
            @global_floor = [@global_floor, floor(g, g_r, mins)].max
            if acc[key]
              acc[key] = [g, acc[key]].max
            else
              acc[key] = g
              queue << key
            end
          end
        end
      end
    end
    max_g
  end

  private def solve_dfs(blueprint)
    @global_floor = 0
    init_key = build_key(1,0,0,0,1,0,0,0)
    dfs(blueprint, init_key, 0, {})
  end

  private def dfs(blueprint, key, geodes, memo)
    return memo[key] if memo[key]

    #puts read_key(key).to_s
    minutes, ore, clay, obs, ore_r, clay_r, obs_r, geode_r = read_key(key)
    max_g = candidates(ore, clay, obs, ore_r, clay_r, obs_r, geode_r, blueprint, minutes).map do |o,c,ob,g,o_r,c_r,ob_r,g_r,mins|
      if mins > @max_minutes
        g
      else
        key = build_key(mins,o,c,ob,o_r,c_r,ob_r,g_r)
        #@global_floor = [@global_floor, floor(g, g_r, mins)].max
        g + dfs(blueprint, key, g + geodes, memo)
      end
    end.max

    memo[key] = max_g
    max_g
  end

  private def candidates(ore, clay, obs, ore_r, clay_r, obs_r, geode_r, blueprint, minutes)
    resources = [ore, clay, obs, 0]
    robots = [ore_r, clay_r, obs_r, geode_r]
    candidates = []
    if minutes == @max_minutes
      candidates << [[0, 0, 0, 0], [0, 0, 0, 0], 0]
    else
      time_left = @max_minutes - minutes
      
      mins_to_build = time_for_geode(blueprint[3], robots, resources)
      has_time, build_time = can_build_robot?(mins_to_build, time_left)
      candidates << [blueprint[3], [0, 0, 0, 1], build_time] if has_time

      if build_time.abs > 0
        obs_needed = robot_needed?(blueprint, robots, resources, 2, time_left)
        mins_to_build = time_for_obs(blueprint[2], robots, resources)
        has_time, build_time = can_build_robot?(mins_to_build, time_left)
        candidates << [blueprint[2], [0, 0, 1, 0], build_time] if obs_needed && has_time

        clay_needed = obs_needed && robot_needed?(blueprint, robots, resources, 1, time_left)
        mins_to_build = time_for_clay(blueprint[1], robots, resources)
        has_time, build_time = can_build_robot?(mins_to_build, time_left)
        candidates << [blueprint[1], [0, 1, 0, 0], build_time] if clay_needed && has_time

        if time_left >= blueprint[0][0] + 2
          ore_needed = robot_needed?(blueprint, robots, resources, 0, time_left)
          mins_to_build = time_for_ore(blueprint[0], robots, resources)
          has_time, build_time = can_build_robot?(mins_to_build, time_left)
          candidates << [blueprint[0], [1, 0, 0, 0], build_time] if ore_needed && has_time
        end

        candidates << [[0, 0, 0, 0], [0, 0, 0, 0], 0] if candidates.length == 0
      end
    end

    ore_needs = blueprint.map { |b| b[0] }.max
    clay_needs = blueprint[2][1]
    obs_needs = blueprint[3][2]

    candidates.map do |costs, robots, mins|
      new_ore = ore + ore_r*(mins+1) - costs[0]
      new_clay = clay + clay_r*(mins+1) - costs[1]
      new_obs = obs + obs_r*(mins+1) - costs[2]
      [
        (ore_r + robots[0] == ore_needs ? [ore_needs, new_ore].min : new_ore),
        (clay_r + robots[1] == clay_needs ? [clay_needs, new_clay].min : new_clay),
        (obs_r + robots[2] == obs_needs ? [obs_needs, new_obs].min : new_obs),
        geode_r*(mins+1),
        ore_r + robots[0],
        clay_r + robots[1],
        obs_r + robots[2],
        geode_r + robots[3],
        minutes + mins + 1
      ]
    end
  end

  private def robot_needed?(blueprint, robots, resources, idx, time_left)
    pays_off = time_left >= (blueprint[3][idx] > 0 ? 3 : 5)
    max_cost = blueprint.map { |b| b[idx] }.max
    not_enough_robots = robots[idx] < max_cost
    not_enough_resources = resources[idx] + robots[idx] * time_left < max_cost * time_left
    
    pays_off && not_enough_robots && not_enough_resources
  end

  private def can_build_robot?(mins_to_build, time_left)
    built_in_time = mins_to_build > -1 && mins_to_build < time_left
    [built_in_time, mins_to_build]
  end

  private def time_for_resource(costs, robots, resources, idx)
    (1.0 * [(costs[idx] - resources[idx]), 0].max / robots[idx]).ceil
  end

  private def time_for_geode(costs, robots, resources)
    return -1 if robots[0] == 0 || robots[2] == 0

    ore_time = time_for_resource(costs, robots, resources, 0)
    obs_time = time_for_resource(costs, robots, resources, 2)
    [ore_time, obs_time].max
  end

  private def time_for_obs(costs, robots, resources)
    return -1 if robots[0] == 0 || robots[1] == 0

    ore_time = time_for_resource(costs, robots, resources, 0)
    clay_time = time_for_resource(costs, robots, resources, 1)
    [ore_time, clay_time].max
  end

  private def time_for_clay(costs, robots, resources)
    return -1 if robots[0] == 0

    time_for_resource(costs, robots, resources, 0)
  end

  private def time_for_ore(costs, robots, resources)
    time_for_resource(costs, robots, resources, 0)
  end

  private def floor(geode, geode_r, minutes)
    minutes_left = @max_minutes - minutes + 1
    geode + geode_r * minutes_left
  end
  
  private def ceiling(geode, geode_r, minutes)
    minutes_left = @max_minutes - minutes + 1
    geode + geode_r*minutes_left + ((minutes_left)*(minutes_left+1))/2
  end

  private def build_key(*args)
    base = 1
    key = 0
    args.each do |arg|
      key += base * arg
      base *= 1000
    end
    key
  end

  private def read_key(key)
    base1 = 1
    base2 = 1000
    res = []
    i = 0
    while i < 8
      res << (key % base2) / base1
      base1 *= 1000
      base2 *= 1000
      i += 1
    end
    res
  end

end