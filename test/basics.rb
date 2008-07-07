here = File.dirname(__FILE__)
require "#{here}/helper"

describe "Casuistry" do
  
  before do    
    @string = File.read("test.css")
    @data = [
        [ '.class_name1 .class_name2 .class_name3', 
            [ 'font-size: 2em;', 'line-height: 3em;', 'border: 1px solid blue;']],
        [ '#milk', 
            ['background-color: blue;', 'border: 1px solid red']]
    ]
    @data2 = [
      [ '#header', ['width: 500px;'] ],
      [ '#header #menu', ['background: gray;']]
    ]
    
    @data3 = [
      ["ul", ["background: red;", "width: 134px;"]], 
      ["ul li .ugly", ["color: green;"]],
      ["ul .smurf .house", ["height: 256px;"]],
      ["ul #asrael", ["padding: 10px;"]],
      [".gargamel", ["margin: 0px;"]],
      [".outer .middle .inner", ["top: 34px;"]]
    ]
    
    @css1 = <<-CSS
ul
{
  background: red;
  width: 134px;
}
ul li .ugly
{
  color: green;
}
ul .smurf .house
{
  height: 256px;
}
ul #asrael
{
  padding: 10px;
}
.gargamel
{
  margin: 0px;
}
.outer .middle .inner
{
  top: 34px;
}
    CSS
  end


  it "interprets unknown ! methods as ids and others as classes" do
    c = Casuistry.new
    c.selectify("smurf!").should == "#smurf"
    c.selectify("smurf").should == ".smurf"
  end

  it "processes cssy code" do
    c = Casuistry.new
    c.instance_eval do
      @background = "red"
    end
    c.process(File.read( "#{here}/fiddle.cssy"))
    c.data.should == @data3
    c.output.should == @css1
  end
  
  
end