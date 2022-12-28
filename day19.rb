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
    @max_minutes = 24
    @blueprints.each_with_index.map do |b, i|
      geodes = solve(b)
      geodes * (i+1)
    end.sum
  end

  def two
    @max_minutes = 32
    product = 1
    @blueprints[0..2].each_with_index.map do |b, i|
      geodes = solve(b)
      product *= geodes
    end.sum
    product
  end

  private def solve(blueprint)
    @global_floor = 0
    init_key = [1,0,0,0,1,0,0,0]
    dfs(blueprint, init_key, 0, {})
  end

  private def dfs(blueprint, key, geodes, memo)
    return memo[key] if memo[key]
    
    minutes, ore, clay, obs, ore_r, clay_r, obs_r, geode_r = key
    max_g = candidates(minutes, ore, clay, obs, ore_r, clay_r, obs_r, geode_r, blueprint).map do |mins,o,c,ob,g,o_r,c_r,ob_r,g_r|
      if mins > @max_minutes
        g
      elsif ceiling(g + geodes, geode_r, mins) >= @global_floor
        nkey = [mins,o,c,ob,o_r,c_r,ob_r,g_r]
        @global_floor = [@global_floor, floor(g + geodes, g_r, mins)].max
        g + dfs(blueprint, nkey, g + geodes, memo)
      else
        0
      end
    end.max

    memo[key] = max_g
    max_g
  end

  private def candidates(minutes, ore, clay, obs, ore_r, clay_r, obs_r, geode_r, blueprint)
    resources = [ore, clay, obs, 0]
    robots = [ore_r, clay_r, obs_r, geode_r]
    candidates = []
    ore_needs = [blueprint[3][0], blueprint[2][0], blueprint[1][0]].max
    clay_needs = blueprint[2][1]
    obs_needs = blueprint[3][2]

    if minutes == @max_minutes
      candidates << build_robot(minutes, ore, clay, obs, ore_r, clay_r, obs_r, geode_r, ore_needs, clay_needs, obs_needs, [0, 0, 0, 0], [0, 0, 0, 0], 0)
    else
      time_left = @max_minutes - minutes
      
      build_time = time_for_geode(blueprint[3], robots, resources)
      has_time = can_build_robot?(build_time, time_left)
      candidates << build_robot(minutes, ore, clay, obs, ore_r, clay_r, obs_r, geode_r, ore_needs, clay_needs, obs_needs, blueprint[3], [0, 0, 0, 1], build_time) if has_time

      if build_time.abs > 0
        obs_needed = robot_needed?(obs_needs, obs_r, obs, time_left, 3)
        build_time = time_for_obs(blueprint[2], robots, resources)
        has_time = can_build_robot?(build_time, time_left)
        candidates << build_robot(minutes, ore, clay, obs, ore_r, clay_r, obs_r, geode_r, ore_needs, clay_needs, obs_needs, blueprint[2], [0, 0, 1, 0], build_time) if obs_needed & has_time

        clay_needed = obs_needed && robot_needed?(clay_needs, clay_r, clay, time_left, 5)
        build_time = time_for_clay(blueprint[1], robots, resources)
        has_time = can_build_robot?(build_time, time_left)
        candidates << build_robot(minutes, ore, clay, obs, ore_r, clay_r, obs_r, geode_r, ore_needs, clay_needs, obs_needs, blueprint[1], [0, 1, 0, 0], build_time) if clay_needed & has_time

        if time_left >= blueprint[0][0] + 2
          ore_needed = robot_needed?(ore_needs, ore_r, ore, time_left, 3)
          build_time = time_for_ore(blueprint[0], robots, resources)
          has_time = can_build_robot?(build_time, time_left)
          candidates << build_robot(minutes,ore, clay, obs, ore_r, clay_r, obs_r, geode_r, ore_needs, clay_needs, obs_needs, blueprint[0], [1, 0, 0, 0], build_time) if ore_needed & has_time
        end

        candidates << build_robot(minutes, ore, clay, obs, ore_r, clay_r, obs_r, geode_r, ore_needs, clay_needs, obs_needs, [0, 0, 0, 0], [0, 0, 0, 0], 0) if candidates.length == 0
      end
    end

    candidates
  end

  private def build_robot(minutes, ore, clay, obs, ore_r, clay_r, obs_r, geode_r, ore_needs, clay_needs, obs_needs, costs, robots, mins)
    new_ore = ore + ore_r*(mins+1) - costs[0]
    new_clay = clay + clay_r*(mins+1) - costs[1]
    new_obs = obs + obs_r*(mins+1) - costs[2]
    [
      minutes + mins + 1,
      (ore_r + robots[0] == ore_needs ? [ore_needs, new_ore].min : new_ore),
      (clay_r + robots[1] == clay_needs ? [clay_needs, new_clay].min : new_clay),
      (obs_r + robots[2] == obs_needs ? [obs_needs, new_obs].min : new_obs),
      geode_r*(mins+1),
      ore_r + robots[0],
      clay_r + robots[1],
      obs_r + robots[2],
      geode_r + robots[3]
    ]
  end

  private def robot_needed?(max_cost, robots, resources, time_left, threshold)
    pays_off = time_left >= threshold
    not_enough_robots = robots < max_cost
    not_enough_resources = resources + robots * time_left < max_cost * time_left
    
    pays_off && not_enough_robots && not_enough_resources
  end

  private def can_build_robot?(build_time, time_left)
    build_time > -1 && build_time < time_left
  end

  private def time_for_resource(cost, robot, resource)
    return 0 if resource >= cost
    (1.0 * (cost - resource) / robot).ceil
  end

  private def time_for_geode(costs, robots, resources)
    return -1 if robots[0] == 0 || robots[2] == 0

    ore_time = time_for_resource(costs[0], robots[0], resources[0])
    obs_time = time_for_resource(costs[2], robots[2], resources[2])
    [ore_time, obs_time].max
  end

  private def time_for_obs(costs, robots, resources)
    return -1 if robots[0] == 0 || robots[1] == 0

    ore_time = time_for_resource(costs[0], robots[0], resources[0])
    clay_time = time_for_resource(costs[1], robots[1], resources[1])
    [ore_time, clay_time].max
  end

  private def time_for_clay(costs, robots, resources)
    return -1 if robots[0] == 0

    time_for_resource(costs[0], robots[0], resources[0])
  end

  private def time_for_ore(costs, robots, resources)
    time_for_resource(costs[0], robots[0], resources[0])
  end

  private def floor(geode, geode_r, minutes)
    minutes_left = @max_minutes - minutes + 1
    geode + geode_r * minutes_left
  end
  
  private def ceiling(geode, geode_r, minutes)
    minutes_left = @max_minutes - minutes + 1
    geode + geode_r*minutes_left + ((minutes_left)*(minutes_left+1))/2
  end

end
