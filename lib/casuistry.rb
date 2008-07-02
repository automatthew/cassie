require 'properties'
# Markaby-ish way to declare CSS
class Casuistry
  
  attr_reader :output
  
  def initialize(selector=nil, upstream_output=nil)
    @selector = selector
    @output = upstream_output || []
  end
  
  def self.process(file)
    cas = File.read(file)
    self.new.instance_eval(cas).join("\n")
  end
  
  # this will need to be an array of actual CSS attributes
  CSS_PROPERTIES.each do |method_name|
    define_method method_name do |*args|
      css_attr = method_name.gsub('_', '-')
      r = "#{css_attr}: #{args.join(' ')};"
      @output << r
      @output
    end
  end
  
  
  # Unknown methods are treated as selector classses and ids
  # per the Markaby standard
  def method_missing(name, &block)
    matches = name.to_s.match( /([\w_]+)!$/)
    local_selector = if matches
      "##{matches[1]}"
    else
      ".#{name}" 
    end
    selector = "#{@selector} #{local_selector}"
    if block
      @output << "#{selector}\n{"
      Casuistry.new.instance_eval(&block).each do |line|
        @output << "  #{line}"
      end
      @output << "}"
    else
      Casuistry.new(local_selector, @output)
    end
  end
  
end
