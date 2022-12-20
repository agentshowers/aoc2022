class Day19
  INPUT = "day19.input"

  def initialize
    @blueprints = File.readlines(INPUT, chomp: true).map do |line|
      line =~ /Blueprint \d+\: Each ore robot costs (\d+) ore\. Each clay robot costs (\d+) ore\. Each obsidian robot costs (\d+) ore and (\d+) clay\. Each geode robot costs (\d+) ore and (\d+) obsidian\./
      [$1.to_i, $2.to_i, $3.to_i, $4.to_i, $5.to_i, $6.to_i]
    end
  end

  def one
    #return 1115
    @max_minutes = 24
    @blueprints.each_with_index.map do |b, i|
      geodes = solve(b, i)
      geodes * (i+1)
    end.sum
  end

  def two
    #return 25056
    @max_minutes = 32
    product = 1
    @blueprints[0..2].each_with_index.map do |b, i|
      product *= solve(b, i)
    end.sum
    product
  end

  private def solve(blueprint, idx)
    init_key = build_key(0,0,0,1,0,0,0,1)
    queue = [init_key]
    acc = { init_key => 0 }
    max_g = 0
    global_floor = 0
    #puts "Solving #{idx}"
    while queue.length > 0
      key = queue.shift
      geode = acc[key]
      ore, clay, obs, ore_r, clay_r, obs_r, geode_r, minutes = read_key(key)
      minutes_left = @max_minutes - minutes + 1
      ceiling = geode + geode_r*minutes_left + ((minutes_left)*(minutes_left+1))/2
      if ceiling >= global_floor
        candidates(ore, clay, obs, geode, ore_r, clay_r, obs_r, geode_r, blueprint, minutes).each do |o,c,ob,g,o_r,c_r,ob_r,g_r,mins|
          if mins > @max_minutes
            max_g = [g, max_g].max
          else
            key = build_key(o,c,ob,o_r,c_r,ob_r,g_r,mins)
            floor = g + g_r * (@max_minutes - mins + 1)
            global_floor = [global_floor, floor].max
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
    #puts "got #{max_g}"
    max_g
  end

  private def candidates(ore, clay, obs, geode, ore_r, clay_r, obs_r, geode_r, blueprint, minutes)
    resources = [ore, clay, obs, geode]
    robots = [ore_r, clay_r, obs_r, geode_r]
    candidates = []
    #puts "at #{minutes} minutes robots: #{robots.to_s} resources: #{resources.to_s}"
    if minutes == @max_minutes
      candidates << [0, 0, 0, 0, 0, 0, 0, 0, 0]
    else
      costs = [blueprint[4], 0, blueprint[5], 0]
      mins_to_build = time_to_build(costs, robots, resources)
      if mins_to_build > -1 && minutes + mins_to_build < @max_minutes
        candidates << build_robot(costs, robots, resources, mins_to_build) + [0, 0, 0, 1, mins_to_build]
        #puts "Building Geode in #{mins_to_build}"
      end

      if mins_to_build.abs > 0
        time_left = @max_minutes - minutes
  
        obs_pays_off = time_left >= 3
        obs_needed = obs_r < blueprint[5]
        obs_needed = obs_needed && obs + obs_r * time_left < blueprint[5] * time_left
        if obs_pays_off && obs_needed
          costs = [blueprint[2], blueprint[3], 0, 0]
          mins_to_build = time_to_build(costs, robots, resources)
          if mins_to_build > -1 && minutes + mins_to_build < @max_minutes
            candidates << build_robot(costs, robots, resources, mins_to_build) + [0, 0, 1, 0, mins_to_build]
            #puts "Building Obsidian in #{mins_to_build}"
          end
        end

        clay_pays_off = time_left >= 5
        clay_needed = obs_needed && clay_r < blueprint[3]
        clay_needed = clay_needed && clay + clay_r * time_left < blueprint[3] * time_left
        if clay_pays_off && clay_needed
          costs = [blueprint[1], 0, 0, 0]
          mins_to_build = time_to_build(costs, robots, resources)
          if mins_to_build > -1 && minutes + mins_to_build < @max_minutes
            candidates << build_robot(costs, robots, resources, mins_to_build) + [0, 1, 0, 0, mins_to_build]
            #puts "Building Clay in #{mins_to_build}"
          end
        end

        ore_pays_off = time_left >= blueprint[0] + 2
        ore_needed = ore_r < [blueprint[1], blueprint[2], blueprint[4]].max
        ore_needed = ore_needed && ore + ore_r * time_left < [blueprint[1], blueprint[2], blueprint[4]].max * time_left
        if ore_needed && ore_pays_off
          costs = [blueprint[0], 0, 0, 0]
          mins_to_build = time_to_build(costs, robots, resources)
          if mins_to_build > -1 && minutes + mins_to_build < @max_minutes
            candidates << build_robot(costs, robots, resources, mins_to_build) + [1, 0, 0, 0, mins_to_build]
            #puts "Building Ore in #{mins_to_build}"
          end
        end

        candidates << [0, 0, 0, 0, 0, 0, 0, 0, 0] if candidates.length == 0
      end
    end
    candidates.map do |a,b,c,d,e,f,g,h,mins|
      [ore + ore_r + a, clay + clay_r + b, obs + obs_r + c, geode + geode_r + d, ore_r + e, clay_r + f, obs_r + g, geode_r + h, minutes + mins + 1]
    end
  end

  private def build_robot(costs, robots, resources, minutes_to_build)
    (0..3).map do |i|
      robots[i]*minutes_to_build - costs[i]
    end
  end


  private def time_to_build(costs, robots, resources)
    return -1 unless (0..3).none? { |i| robots[i] == 0 && costs[i] > 0 }
  
    minutes_to_build = (0..3).map do |i|
      if costs[i] == 0
        0
      else
        (1.0 * [(costs[i] - resources[i]), 0].max / robots[i]).ceil
      end
    end.max
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