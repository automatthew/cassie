# Experimental alternative from Dan Yoder

%w( rubygems functor ).each { |file| require file }
class CSS # :nodoc:

  include Functor::Method

  # Functor needs instance_exec, which needs instance_eval and send ...
  METHODS = %w( class functor instance_eval instance_exec send __send__ __id__ )
  instance_methods.each { |m| undef_method( m ) unless METHODS.include? m }

  
  TAGS = %w( a abbr acronym address area b base bdo big blockquote body br button caption 
    cite code col colgroup dd del dfn div dl dt em fieldset form h1 h2 h3 h4 h5 h6 head hr 
    html i img input ins kbd label legend li link map meta noscript object ol optgroup option 
    p param pre q samp script select small span strong style sub sup table tbody td textarea 
    tfoot th thead title tr tt ul var _ )
  ATTRS = %w( background border clear color display float font height letter_spacing
    line-height list margin max outline padding text )
  COMBINATORS = %w( + / > )
  
   ROWS = %w( height top bottom ) ; COLS = %w( width left right )

  def self.css( &block ) ; @start = block ; end

  def render
    __start ; instance_eval( &( self.class.module_eval { @start } ) )
    @output.reverse.map { |sel, attrs| puts sel.inspect ; "#{sel.join('').strip} { #{attrs} }" }.join("\n")
  end

  def select( s )
    selector = @selectors[-1].dup << s
    @selectors << selector ; @buffers << @buffer
    @buffer = '' ; yield ; @output << [ selector, @buffer ]
    @selectors.pop ; @buffer = @buffers.pop
  end
  
  # grid support
  def units ; 'px' ; end 
  def cols( n ) "#{n}#{units}" ; end
  def rows( n ) "#{n}#{units}" ; end
  
  def method_missing( name, *args, &block ) ; __process( name.to_s, args, block ) ; self ; end
  
  private 
  
  def __start ; @output = [] ; @selectors = [ [] ] ; @selector = [] ; @buffers = [] ; @buffer = '' ; end
  def __open( sel ) @selector << [ sel ] ; end
  def __append( sel ) ( __open( sel ) if @selector.empty? ) or ( @selector[-1] << sel ) ; end
  def __close( block ) s = @selector ; @selector = [] ; select( s, &block ) ; end
  def __combine( op ) @output[-1][0][-1] << op ; end

  functor( :__process, lambda { | name | ATTRS.include?( name ) }, Array, nil ) { | name, args, block | __attribute( name, *args ) } 
  functor( :__process, lambda { | name | TAGS.include?( name ) }, [], nil ) { | sel, args, block | __open( sel )  }
  functor( :__process, lambda { | name | COMBINATORS.include?( name ) }, [], nil ) { | op, args, block | __combine( op )  }
  functor( :__process, String, [], nil ) { | sel, args, block | __append( sel ) }
  functor( :__process, lambda { | name | TAGS.include?( name ) }, [], Proc ) { | sel, args, block | __open( sel ) ; __close( block )  }
  functor( :__process, String, [], Proc ) { | sel, args, block | __append( sel ) ; __close( block ) }
  functor( :__attribute, String, String ) { | name, val | @buffer << "#{name}: #{val};" }
  functor( :__attribute, lambda { | name | COLS.include?( name ) }, Integer ) { | name, val | __attribute( name, cols( val ) ) }
  functor( :__attribute, lambda { | name | ROWS.include?( name ) }, Integer ) { | name, val | __attribute( name, rows( val ) ) }
  functor( :__attribute, String, Hash ) { | name, vals | vals.each { | key, val | __attribute( "#{name}-#{key}", val ) } }

end