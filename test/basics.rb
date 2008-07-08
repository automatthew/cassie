here = File.dirname(__FILE__)
require "#{here}/helper"

describe "Casuistry" do
  
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
    Cssy.process(&proc).should == data
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
    Cssy.process(&proc).should == data
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
    Cssy.process(&proc).should == data
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
    Cssy.process(&proc).should == data
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
    Cssy.process(&proc).should == data
  end


  it "processes strings" do
    fiddle = [
      ["ul", ["background: red;"]],
      ["ul li", ["color: green;"]],
      ["ul p.ugly", ["color: aqua;"]],
      ["ul .smurf.house", ["height: 256px;"]],
      ["ul #asrael", ["padding: 10px;"]],
      [".gargamel", ["margin: 0px;"]],
      [".outer.middle.inner", ["top: 34px;"]]
    ]
    c = Cssy.process(File.read( "#{here}/fiddle.cssy"))
    c.should == fiddle
    # c.output.should == File.read( "#{here}/fiddle.css")
  end
  
  
  
end