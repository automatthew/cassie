%w{rubygems}.each do |dep|
  require dep
end

Version = '0.1.0'

task :default => [:test]

begin
  gem 'echoe', '>=2.7'
  require 'echoe'
  Echoe.new('casuistry', Version) do |p|
    p.project = 'casuistry'
    p.summary = "Generates CSS using Ruby, like Markaby"
    p.author = "Matthew King"
    p.email = "automatthew@gmail.com"
    p.ignore_pattern = /^(\.git).+/
    p.test_pattern = "test/*.rb"
  end
rescue
  "(ignored echoe gemification, as you don't have the Right Stuff)"
end
