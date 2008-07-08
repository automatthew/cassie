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
    # possible states are :closed_block, :chaining, :open_block
    @state = :closed_block
  end
  
  
  # transitions
  def open_block(new_selector)
    case @state
    when :closed_block, :open_block
      combined_selector = [current_selector, new_selector].compact.join(" ")
      @selectors.push combined_selector
      open_properties
    when :chaining
      # puts current_selector, new_selector
      @selectors[-1] = "#{current_selector}#{new_selector}"
      open_properties
    else
      raise "You can't get to :open_block from #{@state.inspect}"
    end
    @state = :open_block
  end
  
  def chaining(new_selector)
    case @state
    when :closed_block, :open_block
      combined_selector = [current_selector, new_selector].compact.join(" ")
      @selectors.push( combined_selector)
    when :chaining
      @selectors[-1] = "#{current_selector}#{new_selector}"
    else
      raise "You can't get to :chaining from #{@state.inspect}"
    end
    @state = :chaining
  end
  
  def closed_block
    case @state
    when :open_block, :closed_block
      @selectors.pop
      @properties.pop
    else
      raise "You can't get to :closed_block from #{@state.inspect}"
    end
    @state = :closed_block
  end
  
  
# methods
  
  def selector_eval(sel)
    if block_given?
      open_block(sel)
      yield
      closed_block
    else
      chaining(sel)
    end
    self
  end
  
  def method_missing(name, &block)
    sel = selectify(name)
    if block_given?
      open_block(sel)
      yield
      closed_block
    else
      chaining(sel)
    end
    self
  end

  def current_selector
      @selectors[-1]
  end
  
  def current_properties
    @properties[-1]
  end
  
  def open_properties
    @properties.push []
    @casuist.data << [current_selector, current_properties ]
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
  

  
  def property(css_attr, *args)
    current_properties << "#{css_attr}: #{args.join(' ')};"
  end
  

  
  
  def selectify(method_name)
    matches = method_name.to_s.match( /([\w_]+)!$/)
    matches ? "##{matches[1]}" : ".#{method_name}"
  end

  
end

Cssy = Casuistry
