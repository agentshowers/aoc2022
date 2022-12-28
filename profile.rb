#!/usr/bin/env ruby
require 'ruby-prof'


day = ARGV[0]
require_relative "day#{day}.rb"
t1 = Time.now

RubyProf.start

day_class = Kernel.const_get("Day#{day}")
day = day_class.new
res1 = day.one
res2 = day.two

result = RubyProf.stop

t2 = Time.now

File.open "profile.html", 'w+' do |file|
  printer = RubyProf::GraphHtmlPrinter.new(result)
  printer.print(file, :min_percent=>0)
end