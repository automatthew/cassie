here = File.dirname(__FILE__)
require "#{here}/helper"
require 'experimental'

describe "A palette" do
  
  it "can be created with name/value pairs" do
    p = Experimental::Palette.new [ ["red", "#ff0000"] ]
    p.colors.should == [ ["red", "#ff0000"] ]
    p.names.should == [ "red" ]
  end
  
  it "can be created with values only" do
    p = Experimental::Palette.new ["#ff0000"]
    p.colors.should == ["#ff0000"]
    p.names.should == []
  end
  
  it "provides access to color values by index" do
    p = Experimental::Palette.new [ ["red", "#ff0000"] ]
    p[0].should == "#ff0000"
  end
  
  it "provides access to colors by name" do
    p = Experimental::Palette.new [ ["red", "#ff0000"] ]
    p["red"].should == "#ff0000"
  end
  
  it "can be converted to a hash" do
    p = Experimental::Palette.new [ ["red", "#ff0000"], ["blue", "#0000ff"] ]
    p.to_hash.should == {"red" => "#ff0000", "blue" => "#0000ff"}
  end
  
end