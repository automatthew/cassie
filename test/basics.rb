here = File.dirname(__FILE__)
require "#{here}/helper"

describe "Casuistry" do
  
  before do    
    @string = File.read("test.css")
  end

  
  it "can process a file" do
    Casuistry.process("#{here}/test.cssy", :color => :red ).should == @string
  end
  
  
end