require 'properties'
require 'tags'

# Markaby-ish way to declare CSS
class Casuistry
  
  METHODS = %w( class instance_eval send __send__ __id__ )
  instance_methods.each { |m| undef_method( m ) unless METHODS.include? m }
  
  attr_reader :data
  
  def initialize(sel=nil)
    @data = []
    @selectors = [ sel ]
    @properties = []
    
    # Primitive state machine
    # possible states are :closed_block, :chain, :open_block
    @state = :closed_block
  end
  
  def self.process(*args,&block)
    self.new.process(*args,&block)
  end
  
  def process(*args, &block)
    if block
      instance_eval(&block)
    else
      instance_eval(args.join("\n"))
    end
    @data
  end
  
  def output
    @data.map do |sel|
      properties = sel.last.join("\n  ")
      "#{sel.first}\n{\n  #{properties}\n}\n"
    end.join
  end



  # Pushes an empty array on the properties stack and registers
  # that array (against the current selector) in @data
  def new_property_set
    @properties.push []
    @data << [@selectors[-1], @properties[-1] ]
  end


  # Declare a CSS selector using a block.  May be chained and nested.
  def selector(sel)
    if block_given?
      open_block(sel)
      yield
      closed_block
    else
      chain(sel)
    end
    self
  end
  
  # Catch unknown methods and treat them as CSS class or id selectors.
  def method_missing(name, &block)
    sel = selectify(name)
    if block_given?
      open_block(sel)
      yield
      closed_block
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

  # Add a property declaration string to the current selector's properties array.
  def property(css_attr, *args)
    @properties[-1] << "#{css_attr}: #{args.join(' ')};"
  end
  
  ##  State transitions
  
  # Push the accumulated selector and a new property array onto the
  # tops of their respected stacks
  def open_block(new_selector)
    case @state
    when :closed_block, :open_block
      combined_selector = [@selectors[-1], new_selector].compact.join(" ")
      @selectors.push combined_selector
      new_property_set
    when :chain
      @selectors[-1] = "#{@selectors[-1]}#{new_selector}"
      new_property_set
    else
      raise "You can't get to :open_block from #{@state.inspect}"
    end
    
    @state = :open_block
  end

  # Pushes accumulated selector on the stack without generating a new properties array.
  def chain(new_selector)
    case @state
    when :closed_block, :open_block
      combined_selector = [@selectors[-1], new_selector].compact.join(" ")
      @selectors.push( combined_selector)
    when :chain
      @selectors[-1] = "#{@selectors[-1]}#{new_selector}"
    else
      raise "You can't get to :chain from #{@state.inspect}"
    end
    
    @state = :chain
  end

  # Pop the selector string and property array for the closing block
  # off of their respective stacks
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


  
  
end

Cssy = Casuistry
