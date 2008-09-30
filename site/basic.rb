css = Cssy.new.process do

  @default = "#212F54"

  body { background_color "#F8F7F1"}
  div.content! { 
    width "700px"; margin "25px auto"

    h1 { color @default }

    a { 
      color @default;
      text_decoration :none
      font_weight :bold
    }

    ul.links! { list_style "url(flower.png)"  }
  }
  
end

css.to_s