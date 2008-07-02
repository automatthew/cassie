# Markaby-ish way to declare CSS
class CSS
  
  attr_reader :output
  
  def initialize(selector=nil, upstream_output=nil)
    @selector = selector
    @output = upstream_output || []
  end
  
  # this will need to be an array of actual CSS attributes
  %w{ font_size line_height border }.each do |method_name|
    define_method method_name do |*args|
      css_attr = method_name.gsub('_', '-')
      r = "#{css_attr}: #{args.join(' ')};\n"
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
      CSS.new.instance_eval(&block).each do |line|
        @output << "  #{line}"
      end
      @output << "}"
    else
      CSS.new(local_selector, @output)
    end
  end
  
end


css = CSS.new
css.instance_eval do

  blick.recent do
    font_size('2em')
    line_height('3em')
  
  end

  milk! do
    border('1px', :solid, :red )
  end

end

puts css.output
# >> .blick .recent
# >> {
# >>   font-size: 2em;
# >>   line-height: 3em;
# >> }
# >>  #milk
# >> {
# >>   border: 1px solid red;
# >> }



