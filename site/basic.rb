@css = Cssy.new; @css.process do

  body { background_color "#F8F7F1"}
  div.content! { 
    width "700px"; margin "25px auto"

    a { 
      color "#212F54";
      text_decoration :none
      font_weight :bold
    }

    ul.links! { list_style "url(flower.png)"  }
  }
  
end

@css.output