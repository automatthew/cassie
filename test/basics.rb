here = File.dirname(__FILE__)
require "#{here}/helper"

describe "Cassandra" do
  
  it "can nest blocks" do
    proc = lambda do
      div do
        form { width "35px" }
        ul do
          li { background :red }
        end
      end
    end
    
    data = [
      ["div", []],
      ["div form", ["width: 35px;"]],
      ["div ul", []],
      ["div ul li", ["background: red;"]]
    ]
    Cssy.process(&proc).data.should == data
  end
  
  it "can chain blocks" do
    proc = lambda do
      p.smurf { color :blue }
      p.gnome.hat { color :red }
    end
    
    data = [
      ["p.smurf", [ "color: blue;"]],
      ["p.gnome.hat", ["color: red;"]]
    ]
    Cssy.process(&proc).data.should == data
  end
  
  it "can nest and chain" do
    proc = lambda do
      div do
        span.ugly { font_family "Arial" }
      end
    end
    
    data = [
      ["div", []],
      ["div span.ugly", ["font-family: Arial;"]]
    ]
    Cssy.process(&proc).data.should == data
  end
  
  it "can chain and nest" do
    proc = lambda do
      ul.monkey do
        li { list_style :none }
      end
    end
    
    data = [
      ["ul.monkey", []],
      ["ul.monkey li", ["list-style: none;"]]
    ]
    Cssy.process(&proc).data.should == data
  end
  
  it "can chain and nest and chain and ..." do
    proc = lambda do
      div do
        div.milk!.toast do
          p.jam { margin :auto }
          hr { background :green }
        end
        
        p { border :none }
      end
    end
    
    data = [
      ["div", []],
      ["div div#milk.toast", []],
      ["div div#milk.toast p.jam", ["margin: auto;"]],
      ["div div#milk.toast hr", ["background: green;"]],
      ["div p", ["border: none;"]]
    ]
    Cssy.process(&proc).data.should == data
  end


  it "processes strings" do
    basics = [
      ["div", ["background: red;", "width: 9934px;"]],
      ["div ul li", ["color: green;"]],
      ["div p.ugly.truly", ["color: aqua;"]],
      ["div .smurf.house", ["height: 256px;"]],
      ["div #menu", ["padding: 10px;"]],
      [".gargamel", ["margin: 0px;"]],
      [".outer.middle.inner", ["top: 34px;"]]
    ]
    c = Cssy.new
    c.process(File.read( "#{here}/basics.cssy"))
    c.data.should == basics
    c.to_s.should == File.read( "#{here}/basics.css")
  end
  
  
  
end