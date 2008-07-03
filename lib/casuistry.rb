require 'properties'
# Markaby-ish way to declare CSS
class Casuistry
  
  attr_reader :output
  
  def initialize(selector=nil, upstream_output=nil)
    @selector = selector
    @output = upstream_output || []
  end
  
  def self.process(file, assigns={})
    cssy = File.read(file)
    c = self.new
    c.instance_eval do
      assigns.each { |key,val| instance_variable_set("@#{key}",val) }
    end
    c.instance_eval(cssy).join("\n")
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
  
  def selectify(method_name)
    matches = method_name.to_s.match( /([\w_]+)!$/)
    matches ? "##{matches[1]}" : ".#{method_name}"
  end
  
  
  # Unknown methods are treated as selector classses and ids
  # per the Markaby standard
  def method_missing(name, &block)
    local_selector = selectify(name)
    selector = @selector ? "#{@selector} #{local_selector}" : local_selector
    if block
      @output << "#{selector}\n{"
      Property.new.instance_eval(&block).each do |line|
        @output << "  #{line}"
      end
      @output << "}"
    else
      Casuistry.new(selector, @output)
    end
  end
  
end

class Property
    
  def initialize(upstream_output=nil)
    @output = upstream_output || []
  end
  
  CSS_PROPERTIES.each do |method_name|
    define_method method_name do |*args|
      css_attr = method_name.gsub('_', '-')
      r = "#{css_attr}: #{args.join(' ')};"
      @output << r
      @output
    end
  end
  
end
