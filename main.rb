#!/usr/bin/env ruby

require 'json'
require 'optparse'
require 'uri'
require 'net/http'

DAYS = 25

class WrongOutputError < StandardError
  def initialize(day, part, expected, actual)
    super("Failed day #{day} part #{part} 😔\nExpected: \e[32m#{expected}\e[0m\nActual: \e[31m#{actual}\e[0m")
  end
end

class MissingCookieError < StandardError
  def initialize
    super("\e[31mERROR:\e[0m Missing 'cookie' file.\nCreate it or download the inputs manually or use the -s option")
  end
end

def download_inputs(range, force)
  raise MissingCookieError.new if !File.exist?("cookie")
  cookie = File.read("cookie").strip

  range.each do |n|
    printf("\r\e[KDownloading inputs #{n}/#{DAYS}")
    filename = "day#{n.to_s.rjust(2, '0')}.input"

    if force || !File.exist?(filename)
      uri = URI("https://adventofcode.com/2022/day/#{n}/input")
      req = Net::HTTP::Get.new(uri)
      req["Cookie"] = "session=#{cookie}"
      res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) { |http| http.request(req) }
      File.write(filename, res.body)
    end
  end
end

def solve(range)
  range.map do |n|
    printf("\r\e[KSolving #{n}/#{DAYS}")
    require_relative "day#{n.to_s.rjust(2, '0')}.rb"
  
    day_class = Kernel.const_get("Day#{n}")
    t1 = Time.now
    day = day_class.new
    res1 = day.one
    res2 = day.two
    t2 = Time.now
    time = 1000.0 * (t2 - t1)

    [n, res1, res2, time]
  end
end

def validate(solutions, filename)
  printf "\r\e[KComparing outputs"
  expected = JSON.parse(File.read(filename))
  solutions.each do |n, pt1, pt2, _|
    raise WrongOutputError.new(n, 1, expected[n-1][0], pt1) if expected[n-1][0] != pt1
    raise WrongOutputError.new(n, 2, expected[n-1][1], pt2) if expected[n-1][1] != pt2
  end
end

def pretty_print(solutions)
  printf("\r\e[K")
  total_time = solutions.map {_1[3]}.sum

  puts "-----------------------------------------------------------------"
  puts "| Day | Part 1               | Part 2               | Time       |"
  puts "-----------------------------------------------------------------"


  solutions.each do |day, pt1, pt2, time|
    if time < 100.0
      color_code = 32
    elsif time < 1000.0
      color_code = 33
    else
      color_code = 31
    end
    time_str = "#{time.round(2).to_s} ms"
    puts sprintf("| %-3s | %-20s | %-20s | \e[#{color_code}m%-10s\e[0m |", day, pt1, pt2, time_str)
  end

  puts "-----------------------------------------------------------------\n"
  puts " "*42 + "Total time: #{total_time.round(2)} ms"
end

options = {}
optparser = OptionParser.new do |opts|
  opts.banner = "Usage: main.rb [options]"

  opts.on("-v", "--validate FILENAME", "Validate the solutions against an existing file") do |file|
    options[:solutions_file] = file
  end

  opts.on("-d", "--day DAY", "Runs only the selected day") do |day|
    options[:day] = day
  end

  opts.on("-s", "--skip", "Skip downloading input files") do |s|
    options[:skip] = s
  end

  opts.on("-f", "--force", "Re-downloads all input files") do |f|
    options[:force] = f
  end

end
optparser.parse!

range = (1..DAYS)
if options[:day]
  day = options[:day].to_i
  range = (day..day)
end

puts "******************************************************************"
puts "*                                                                *"
puts "*                  🎄🎄 Advent of Code 2022 🎄🎄                 *"
puts "*                                                                *"
puts "******************************************************************"
puts ""

begin
  download_inputs(range, options[:force]) unless options[:skip]
  solutions = solve(range)
  validate(solutions, options[:solutions_file]) if options[:solutions_file]
  pretty_print(solutions)
rescue WrongOutputError => e
  printf("\r\e[K")
  puts e.message
rescue MissingCookieError => e
  printf("\r\e[K")
  puts e.message
  puts ""
  puts optparser.help
end
  