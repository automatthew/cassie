module Experimental
    
    class Palette
      
      attr_reader :colors
      
      # Palette colors may be supplied as an array of values, or an array of name/value pairs:
      #   Palette.new [ "#eeeeee", "#666600" ]
      #   Palette.new [ ["red", "#ff0000"], ["blue", "#0000ff"] ]
      
      def initialize(color_array)
        @colors = color_array
      end
      
      def names
        n = []
        # We could use #map here, but then I'd have to use #compact
        @colors.each { |c| c.respond_to?( :first ) ? n << c.first : nil }
        n
      end

      def [](arg)
        color = arg.is_a?(Integer) ? @colors[arg] : @colors.assoc(arg)
        color.respond_to?(:last) ? color.last : color
      end
      
      def to_hash
        Hash[ *@colors.flatten ]
      end
      
    end
    
    class ColourLovers < Palette
      
      require 'net/http'
      require 'hpricot'
      
      attr_reader :image_url
      
      def initialize(palette_id, names=false)
        # This appears to be a better URL for our purposes
        uri = URI.parse( "http://www.colourlovers.com/api/palette/#{palette_id}?format=xml")
        xml = Hpricot.XML( Net::HTTP.get( uri ))
        colors = xml.at("colors").search("hex").map { |c| c.inner_text }
        
        if names
          cnames=[] 
          colors.each do |c|
            # interpolation is faster than concatenation
            uri = URI.parse( "http://www.colourlovers.com/api/color/#{c}?format=xml")
            xml = Hpricot.XML( Net::HTTP.get( uri ))
            cnames << xml.at("title").inner_text
          end
          super colors.map! { |c| [cnames.shift, c] }
        else
          super colors
        end
      end
      
    end
end