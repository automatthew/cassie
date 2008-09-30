here = File.dirname(__FILE__)
require "#{here}/helper"

describe "Assigns hash" do
  
  it "becomes instance variables" do
    assigns = { :width => "350px", :background => :red }
    proc = lambda do
      div do
        form { width @width }
        ul do
          li { background @background }
        end
      end
    end
    
    data = [
      ["div", []],
      ["div form", ["width: 350px;"]],
      ["div ul", []],
      ["div ul li", ["background: red;"]]
    ]
    Cssy.process(assigns, &proc).data.should == data
  end
end

