require 'properties'
require 'tags'

# Markaby-ish way to declare CSS
class Casuistry
  
  include Tags
  
  attr_reader :data, :assigns
  
  def self.process(file)
    cssy = File.read(file)
    c = self.new
    c.process(cssy)
    c
  end
  
  def process(string)
    self.instance_eval(string)
  end
  
  def initialize(selector=nil)
    @selector = selector
    @data = []
  end
  
  def output
    output = ""
    @data.each do |selector|
      output << selector.first
      properties = selector.last.map { |s| "  #{s}" }.join("\n")
      output << "\n{\n#{properties}\n}\n"
    end
    output
  end
  
  def selector_eval(*args, &block)
    selector = args.compact.join(" ")
    Selector.new(selector, self).instance_eval(&block)
  end

  
  def selectify(method_name)
    matches = method_name.to_s.match( /([\w_]+)!$/)
    matches ? "##{matches[1]}" : ".#{method_name}"
  end
  
  def method_missing(name, &block)
    selector = selectify(name)
    if block
      selector_eval(@selector, selector, &block)
    else
      x = [@selector, selector].compact.join(' ')
      Selector.new(x, self)
    end
  end
  
end

class Selector
  include Tags
  def initialize(base_selector, casuist)
    @selector = base_selector
    @casuist = casuist
  end

  
  def selector_eval(*args, &block)
    selector = args.compact.join(" ")
    if block
      Selector.new(selector, @casuist).instance_eval(&block)
    else
       Selector.new(selector, @casuist)
    end
  end
  
  CSS_PROPERTIES.each do |method_name|
    define_method method_name do |*args|
      css_attr = method_name.gsub('_', '-')
      property(css_attr, args)
    end
  end
  
  def properties
    if @properties
      return @properties
    else
      @properties ||= []
      @casuist.data << [@selector, @properties]
      @properties
    end
  end
  
  def property(css_attr, *args)
    properties << "#{css_attr}: #{args.join(' ')};"
  end
  
  def selectify(method_name)
    matches = method_name.to_s.match( /([\w_]+)!$/)
    matches ? "##{matches[1]}" : ".#{method_name}"
  end
  
  def method_missing(name, &block)
    selector = selectify(name)
    if block
      selector_eval(@selector, selector, &block)
    else
      x = [@selector, selector].join(' ')
      Selector.new(x, @casuist)
    end
  end
  
end

Cssy = Casuistry
