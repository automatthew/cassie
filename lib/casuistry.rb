require 'properties'
require 'tags'

# Markaby-ish way to declare CSS
class Casuistry
  
  include Tags
  
  attr_reader :data, :assigns
  
  def self.process(*args,&block)
    self.new.process(*args,&block)
  end
      
  def initialize(selector=nil)
    @selector = selector
    @data = []
  end
  
  def process(*args, &block)
    if block
      Selector.new(@selector, self).instance_eval(&block)
    else
      Selector.new(@selector, self).instance_eval(args.join("\n"))
    end
    @data
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
  
end

class Selector
  
  def initialize(base_selector, casuist)
    @selectors = [ base_selector ]
    @properties = []
    @casuist = casuist
    # possible states are :rest, :chaining, :processing
    @state = :rest
  end
  
  
  # transitions
  def processing(new_selector)
    case @state
    when :rest
      combined_selector = [current_selector, new_selector].compact.join(" ")
      @selectors.push combined_selector
      @properties.push []
      @casuist.data << [current_selector, current_properties ]
      puts @state = :processing
    when :chaining
      current_selector = "#{current_selector}#{new_selector}"
      @properties.push []
      @casuist.data << [current_selector, current_properties ]
      puts @state = :processing
    else
      raise "You can't get to :processing from #{@state.inspect}"
    end
  end
  
  def chaining(new_selector)
    case @state
    when :rest
      combined_selector = [current_selector, new_selector].compact.join(" ")
      @selectors.push combined_selector
      puts @state = :chaining
    when :chaining
      current_selector = "#{current_selector}#{new_selector}"
    else
      raise "You can't get to :chaining from #{@state.inspect}"
    end
  end
  
  def rest
    case @state
    when :processing
      @selectors.pop
      @properties.pop
      puts @state = :rest
    else
      raise "You can't get to :rest from #{@state.inspect}"
    end
  end
  
  
# methods

  def current_selector
      @selectors[-1]
  end
  
  def current_properties
    @properties[-1]
  end

  # define tag methods to delegate to selector_eval
  methods =  Tags::HTML_TAGS.map do |tag|
    <<-METHOD
    def #{tag}(&block)
      selector_eval('#{tag}', &block)
    end
    METHOD
  end.join

  module_eval methods
  
  CSS_PROPERTIES.each do |method_name|
    define_method method_name do |*args|
      css_attr = method_name.gsub('_', '-')
      property(css_attr, args)
    end
  end
  
  
  def selector_eval(sel)
    if block_given?
      processing(sel)
      yield
      rest
    else
      chaining(sel)
    end
    self
  end
  
  def method_missing(name, &block)
    sel = selectify(name)
    if block_given?
      processing(sel)
      yield
      rest
    else
      chaining(sel)
    end
    self
  end
  
  def property(css_attr, *args)
    current_properties << "#{css_attr}: #{args.join(' ')};"
  end
  

  
  
  def selectify(method_name)
    matches = method_name.to_s.match( /([\w_]+)!$/)
    matches ? "##{matches[1]}" : ".#{method_name}"
  end

  
end

Cssy = Casuistry
