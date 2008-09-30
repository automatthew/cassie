here = File.dirname(__FILE__)
require "#{here}/helper"

describe "CSS comment method" do
  
  it "can be applied at the property level" do
    Cssy.process do
      div do
        ul do
          li do 
            add_comment "What an ugly list!"
            background :red
          end
        end
      end
    end.to_s.should == <<-STRING
div ul li {
  /* What an ugly list! */
  background: red;
}
STRING
  end
  
  it "can be used in helper methods at property level" do

    Cssy.process do
      def red_comment; add_comment "What an ugly list!"; :red; end
      
      div do
        ul do
          li do 
            background red_comment
          end
        end
      end
    end.to_s.should == <<-STRING
div ul li {
  /* What an ugly list! */
  background: red;
}
STRING

  end
end
