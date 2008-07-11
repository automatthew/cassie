require 'benchmark'
require 'rubygems'
require 'ruby-prof'
here = File.dirname(__FILE__)
require "#{here}/helper"

n = 1000

Benchmark.bm do |x|
  x.report "fiddle.css    " do
    n.times do
      css = File.read "#{here}/fiddle.css"
    end
  end
  
  x.report "fiddle.cssy   " do
    n.times do
      c = Cssy.new
      c.process(File.read("#{here}/fiddle.cssy"))
      css = c.output
    end
  end
  
  x.report "blog.css      " do
    n.times do
      css = File.read "#{here}/blog.css"
    end
  end
  
  x.report "blog.cssy     " do
    n.times do
      c = Cssy.new
      c.process(File.read("#{here}/blog.cssy"))
      css = c.output
    end
  end
  
end

result = RubyProf.profile do
  c = Cssy.new
  c.process(File.read("#{here}/blog.cssy"))
  # css = c.output
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT, 0)

printer = RubyProf::GraphPrinter.new(result)
printer.print(STDOUT, 0)