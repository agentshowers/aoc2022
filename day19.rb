class Day19
  INPUT = "day19.input"

  def initialize
    @blueprints = File.readlines(INPUT, chomp: true).map do |line|
      line =~ /Blueprint \d+\: Each ore robot costs (\d+) ore\. Each clay robot costs (\d+) ore\. Each obsidian robot costs (\d+) ore and (\d+) clay\. Each geode robot costs (\d+) ore and (\d+) obsidian\./
      [$1.to_i, $2.to_i, $3.to_i, $4.to_i, $5.to_i, $6.to_i]
    end
    pregenerate_ceiling
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
      elsif ceiling(o, ob, g + geodes, o_r, ob_r, g_r, mins, blueprint[4], blueprint[5]) >= @global_floor
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
    ore_needs = [blueprint[4], blueprint[2], blueprint[1]].max
    clay_needs = blueprint[3]
    obs_needs = blueprint[5]

    if minutes == @max_minutes
      candidates << build_robot(minutes, ore, clay, obs, ore_r, clay_r, obs_r, geode_r, ore_needs, clay_needs, obs_needs, [0, 0, 0], [0, 0, 0, 0], 0)
    else
      time_left = @max_minutes - minutes
      
      build_time = time_for_geode(blueprint[4], blueprint[5], robots, resources)
      has_time = can_build_robot?(build_time, time_left)
      candidates << build_robot(minutes, ore, clay, obs, ore_r, clay_r, obs_r, geode_r, ore_needs, clay_needs, obs_needs, [blueprint[4], 0, blueprint[5]], [0, 0, 0, 1], build_time) if has_time

      if build_time.abs > 0
        obs_needed = robot_needed?(obs_needs, obs_r, obs, time_left, 3)
        build_time = time_for_obs(blueprint[2], blueprint[3], robots, resources)
        has_time = can_build_robot?(build_time, time_left)
        candidates << build_robot(minutes, ore, clay, obs, ore_r, clay_r, obs_r, geode_r, ore_needs, clay_needs, obs_needs, [blueprint[2], blueprint[3], 0], [0, 0, 1, 0], build_time) if obs_needed & has_time

        clay_needed = obs_needed && robot_needed?(clay_needs, clay_r, clay, time_left, 5)
        build_time = time_for_clay(blueprint[1], robots, resources)
        has_time = can_build_robot?(build_time, time_left)
        candidates << build_robot(minutes, ore, clay, obs, ore_r, clay_r, obs_r, geode_r, ore_needs, clay_needs, obs_needs, [blueprint[1], 0, 0], [0, 1, 0, 0], build_time) if clay_needed & has_time

        if time_left >= blueprint[0] + 2
          ore_needed = robot_needed?(ore_needs, ore_r, ore, time_left, 3)
          build_time = time_for_ore(blueprint[0], robots, resources)
          has_time = can_build_robot?(build_time, time_left)
          candidates << build_robot(minutes,ore, clay, obs, ore_r, clay_r, obs_r, geode_r, ore_needs, clay_needs, obs_needs, [blueprint[0], 0, 0], [1, 0, 0, 0], build_time) if ore_needed & has_time
        end

        candidates << build_robot(minutes, ore, clay, obs, ore_r, clay_r, obs_r, geode_r, ore_needs, clay_needs, obs_needs, [0, 0, 0], [0, 0, 0, 0], 0) if candidates.length == 0
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

  private def time_for_geode(ore_cost, obs_cost, robots, resources)
    return -1 if robots[0] == 0 || robots[2] == 0

    ore_time = time_for_resource(ore_cost, robots[0], resources[0])
    obs_time = time_for_resource(obs_cost, robots[2], resources[2])
    [ore_time, obs_time].max
  end

  private def time_for_obs(ore_cost, clay_cost, robots, resources)
    return -1 if robots[0] == 0 || robots[1] == 0

    ore_time = time_for_resource(ore_cost, robots[0], resources[0])
    clay_time = time_for_resource(clay_cost, robots[1], resources[1])
    [ore_time, clay_time].max
  end

  private def time_for_clay(ore_cost, robots, resources)
    return -1 if robots[0] == 0

    time_for_resource(ore_cost, robots[0], resources[0])
  end

  private def time_for_ore(ore_cost, robots, resources)
    time_for_resource(ore_cost, robots[0], resources[0])
  end

  private def floor(geode, geode_r, minutes)
    minutes_left = @max_minutes - minutes + 1
    geode + geode_r * minutes_left
  end
  
  private def ceiling(ore, obs, geode, ore_r, obs_r, geode_r, minutes, ore_cost, obs_cost)
    if obs >= obs_cost
      time_for_obs = 0
    else
      time_for_obs = @ceiling_cache[obs_cost][obs][obs_r]
    end
    if ore >= ore_cost
      time_for_ore = 0
    else
      time_for_ore = @ceiling_cache[ore_cost][ore][ore_r]
    end
    minutes_left = @max_minutes - minutes + 1
    current_production = geode + geode_r*minutes_left
    minutes_left -= [time_for_obs, time_for_ore].max
    current_production + ((minutes_left)*(minutes_left+1))/2
  end

  private def pregenerate_ceiling
    @ceiling_cache = Array.new(21) { Array.new(20) { Array.new(21, 1) } }
    (0..20).each do |cost|
      (0..19).each do |resource|
        next if resource >= cost
        (0..20).each do |robot|
          if resource + robot < cost
            @ceiling_cache[cost][resource][robot] = ((0.5 - robot) + Math.sqrt((0.5 - robot)**2 + 2*(cost - resource))).ceil
          end
        end
      end
    end
  end

end
