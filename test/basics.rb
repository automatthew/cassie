here = File.dirname(__FILE__)
require "#{here}/helper"

describe "Casuistry" do
  
  before do
    @css = Casuistry.new
    @css.instance_eval do
      class_name1.class_name2 do
        font_size('2em')
        line_height('3em')

      end
      milk! do
        background_color(:blue)
        border('1px', :solid, :red )
      end
    end
    
    @string = <<END
.class_name1 .class_name2
{
  font-size: 2em;
  line-height: 3em;
}
 #milk
{
  background-color: blue;
  border: 1px solid red;
}
END
    @string = @string.chomp
  end
  
  it "can generate CSS directly" do
    @css.output.join("\n").should == @string
  end
  
  it "can process a file" do
    Casuistry.process("#{here}/test.cssy").should == @string
  end
  
  
end