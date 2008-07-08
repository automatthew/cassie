require 'properties'
require 'tags'

# Markaby-ish way to declare CSS
class Casuistry
    
  attr_reader :data
  
  def self.process(*args,&block)
    self.new.process(*args,&block)
  end
      
  def initialize(sel=nil)
    @data = []
    @selectors = [ sel]
    @properties = []
    
    # possible states are :closed_block, :chain, :open_block
    @state = :closed_block
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
    output = ""
    @data.each do |sel|
      output << sel.first
      properties = sel.last.map { |s| "  #{s}" }.join("\n")
      output << "\n{\n#{properties}\n}\n"
    end
    output
  end
  
    # state transitions
    def open_block(new_selector)
      case @state
      when :closed_block, :open_block
        combined_selector = [current_selector, new_selector].compact.join(" ")
        @selectors.push combined_selector
        new_property_set
      when :chain
        @selectors[-1] = "#{current_selector}#{new_selector}"
        new_property_set
      else
        raise "You can't get to :open_block from #{@state.inspect}"
      end
      
      @state = :open_block
    end

    def chain(new_selector)
      case @state
      when :closed_block, :open_block
        combined_selector = [current_selector, new_selector].compact.join(" ")
        @selectors.push( combined_selector)
      when :chain
        @selectors[-1] = "#{current_selector}#{new_selector}"
      else
        raise "You can't get to :chain from #{@state.inspect}"
      end
      
      @state = :chain
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


  # normal methods

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

    def current_selector
        @selectors[-1]
    end

    def current_properties
      @properties[-1]
    end

    def new_property_set
      @properties.push []
      @data << [current_selector, current_properties ]
    end

    # define tag methods to delegate to selector
    methods =  Tags::HTML_TAGS.map do |tag|
      <<-METHOD
      def #{tag}(&block)
        selector('#{tag}', &block)
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
