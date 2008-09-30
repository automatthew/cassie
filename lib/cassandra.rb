require 'properties'
require 'tags'

# Cassandra is a CSS generator that takes Ruby blocks as input.  You can call her Cssy, for short.
# At her grubbiest, Cssy gives you selector and property methods you can use for direct declarations
# 
#   css = Cssy.process do
#     selector "div#main" do
#       property "margin-left", "100px"
#       selector "a" do
#         property "color", "red"
#       end
#     end
#   end
# 
# Cssy cleans up real nice, though:
# 
#   css = Cssy.process do
#     div.main! do
#       margin_left "100px"
#       a { color :red }
#     end
#   end
#
# Chained methods on a selector represent classes and ids (as in Markaby).
# Note that the "margin-left" property is declared with a method named margin_left.  Hyphens in 
# property names become underscores in Cssy method names.
# In property declarations, you can use symbols for CSS keywords (e.g. :red, :none, :absolute, :left).
# 
# All the processing takes place in a single Cssy instance, so you can set instance variables and define helper methods, either directly on the instance, or mixed in from a module.
# 
#   css.instance_eval do
#     @fg, @bg = "#333", "#ccc"
#     def invert
#       color @bg
#       background @fg
#     end
#   end
# 
# Once an instance of Cssy is all loaded up with generating goodness, use to_s to output the CSS.


class Cassandra
  
  # Clear out unneeded methods
  METHODS = %w( class instance_eval send __send__ __id__ instance_variable_set )
  instance_methods.each { |m| undef_method( m ) unless METHODS.include? m }
  
  attr_reader :data
  
  # Create a new instance of Cssy, optionally with a base selector
  # 
  #   css = Cssy.new
  #   
  #   header = Cssy.new("div#header")
  def initialize(sel=nil)
    @data = []
    @selectors = [ sel ]
    @properties = []
    
    # Primitive state machine
    # possible states are :closed_block, :chain, :open_block
    @state = :closed_block
  end
  
  def instance_variables(hashlike)
    hashlike.each do |key,val|
      instance_variable_set("@#{key}",val)
    end
  end
  
  # Create a new instance and process the supplied block, returning the instance.
  # 
  #   css = Cssy.process do
  #     ul do
  #       li { list_style :none }
  #     end
  #   end
  def self.process(*args, &block)
    self.new.process(*args, &block)
  end
  
  # Process the supplied block (storing the result internally as an array in @data).  
  # Returns the Cssy instance.
  # 
  # If no block is given, join all arguments with "\n" and eval the result.  Dubious utility.
  def process(*args, &block)
    assigns = args[0]      if args[0].is_a? Hash
    string, assigns = args if args[0].is_a? String
    instance_variables(assigns) if assigns
    if block
      instance_eval(&block)
    elsif string
      instance_eval(string)
    end
    self
  end
  
  # Output CSS as a string
  def to_s
    @data.map do |sel|
      properties = sel.last.join("\n  ")
      "#{sel.first} {\n  #{properties}\n}\n"
    end.join
  end
  
  # Declare a CSS selector using a block.  May be chained and nested.
  # 
  #   selector "a:visited" do
  #     color :gray
  #   end
  def selector(sel)
    if block_given?
      open(sel)
      yield
      close
    else
      chain(sel)
    end
    self
  end
  
  alias :s :selector
  
  # Add a property declaration for the current selector.
  # 
  #   property "margin-bottom", "42px" 
  #
  def property(css_attr, *args)
    @properties[-1] << "#{css_attr}: #{args.join(' ')};"
  end

  # Catch unknown methods and treat them as CSS class or id selectors.  This may
  # go away in future releases.
  # 
  #   monkey { padding "24px" }
  # 
  def method_missing(name, &block)
    sel = selectify(name)
    if block_given?
      open(sel)
      yield
      close
    else
      chain(sel)
    end
    self
  end
  
  # bang methods represent CSS ids.  Otherwise CSS classes.
  def selectify(method_name)
    matches = method_name.to_s.match( /([\w_]+)!$/)
    matches ? "##{matches[1]}" : ".#{method_name}"
  end

  private

  # define tag methods that delegate to selector
  methods =  HTML_TAGS.map do |tag|
    <<-METHOD
    def #{tag}(&block)
      selector('#{tag}', &block)
    end
    METHOD
  end.join; module_eval(methods)

  # define methods for CSS properties.
  CSS_PROPERTIES.each do |method_name|
    define_method method_name do |*args|
      css_attr = method_name.gsub('_', '-')
      property(css_attr, args)
    end
  end  
  
  # Pushes an empty array on the properties stack and registers
  # that array (against the current selector) in @data
  def new_property_set
    @properties.push []
    @data << [@selectors[-1], @properties[-1] ]
  end
  
  ##  State transitions
  
  # Push the accumulated selector and a new property array onto the
  # tops of their respected stacks
  def open(new_selector)
    case @state
    when :closed_block, :open_block
      combined_selector = [@selectors[-1], new_selector].compact.join(" ")
      @selectors.push combined_selector
      new_property_set
    when :chain
      @selectors[-1] = "#{@selectors[-1]}#{new_selector}"
      new_property_set
    else
      raise "#open not available when state is #{@state.inspect}"
    end
    
    @state = :open_block
  end

  # Pushes accumulated selector on the stack without generating a new properties array.
  def chain(new_selector)
    case @state
    when :closed_block, :open_block
      combined_selector = [@selectors[-1], new_selector].compact.join(" ")
      @selectors.push combined_selector
    when :chain
      @selectors[-1] = "#{@selectors[-1]}#{new_selector}"
    else
      raise "#chain not available when state is #{@state.inspect}"
    end
    
    @state = :chain
  end

  # Pop the selector string and property array for the closing block
  # off of their respective stacks
  def close
    case @state
    when :open_block, :closed_block
      @selectors.pop
      @properties.pop
    else
      raise "#close not available when state is #{@state.inspect}"
    end
    
    @state = :closed_block
  end
end

Cssy = Cassy = Cassandra
