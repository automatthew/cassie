require 'rubygems'

Version = '0.2.3'

task :default => [ :test ]

begin
  gem 'echoe', '>=2.7'
  require 'echoe'
  Echoe.new('cassandra', Version) do |p|
    p.project = 'cassandra'
    p.summary = "Generates CSS using Ruby, like Markaby"
    p.author = "Matthew King"
    p.email = "automatthew@gmail.com"
    p.ignore_pattern = /^(\.git).+/
    p.test_pattern = "test/*.rb"
  end
rescue
  "(ignored echoe gemification, as you don't have the Right Stuff)"
end

module Rake::TaskManager
  def delete_task(task_class, *args, &block)
    task_name, deps = resolve_args(args)
    @tasks.delete(task_class.scope_name(@scope, task_name).to_s)
  end
end
class Rake::Task
  def self.delete_task(args, &block) Rake.application.delete_task(self, args, &block) end
end
def delete_task(args, &block) Rake::Task.delete_task(args, &block) end
  
delete_task :publish_docs

desc "Publish rdocs to rubyforge"
task :publish_docs => [ :clean, :docs ] do
  config = YAML.load(File.read(File.expand_path("~/.rubyforge/user-config.yml")))
  pub = Rake::SshDirPublisher.new "#{config["username"]}@rubyforge.org", 
    "/var/www/gforge-projects/cassandra/rdoc", 
    'doc'
  pub.upload
end

task :publish_site => [ :compile ] do
  cmd = "scp -qr site/*.{html,css,jpg,png} automatthew@rubyforge.org:/var/www/gforge-projects/cassandra"
  puts "Uploading: #{cmd}"
  system(cmd)
end

def rubyforge_config
  @rubyforge_config ||= YAML.load(File.read(File.expand_path("~/.rubyforge/user-config.yml")))
end



# List all the desired pages as dependencies on :compile
desc "compile templates to html and css"
task :compile => %w{ site/index.html site/basic.css site/ruby.css }

task :clean do
  f = FileList['site/**/*.html', 'site/*.css']
  puts f; rm f
end

rule '.html' => [ '.mab' ] do |t|
  mab(t.source, t.name)
end

file 'site/index.html' => [ 'site/basic.css', 'site/index.mab' ]

rule '.css' => [ '.cssy' ] do |t|
  cssify(t.source, t.name)
end
  
require 'markaby'
$:.unshift "lib"
require 'cassandra'

def mab(source, target)
  mab = Markaby::Builder.new
  result = mab.instance_eval(File.read(source))
  File.open(target, 'w') do |f|
    f.puts result
  end
end

def cssify(source, target)
  cssy = File.read(source)
  c = Cssy.new.process(cssy, { :default => "#212F54" })
  File.open(target, 'w') do |f|
    f.puts c.to_s
  end
end


