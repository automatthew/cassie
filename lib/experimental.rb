module Experimental
  module Palettes
    
    class Palette
      
      def initialize(colors)
        @colors = []; @names = {}
        if colors.first.length == 2 # This is how we prefer our input, but you can make a palette without it.
          colors.each {|n, c| @names[n] = c; @colors << c }
        else
          colors.each {|c| @colors << c }
        end
      end

      def [](arg)
        if arg.is_a? Integer
          @colors[arg]
        else
          @names[arg]
        end
      end
      
    end
    
    class ColourLovers < Palette
      
      require 'net/http'
      require 'hpricot'
      
      def initialize(args, names=false)
        if args.is_a? Hash
          raise ArgumentError if args[:keywords].nil?
          params = args.inject {|p,(a,v)| p + "#{a}=#{b}&" } # We will always add a format, so don't fear the trailing '&'
        else
          params = "keywords=#{args.gsub!(' ','+')}&"    # we can do more filtering, if you want
        end
        xml = Hpricot.XML( Net::HTTP.get( URI.parse( 'http://www.colourlovers.com/api/palettes?' + params + 'format=xml' )))
        colors = []
        xml.at("colors").search("hex").each {|c| colors << c.inner_text} #inject doesn't seem to work :(
        
        if names
          cnames=[] 
          colors.each {|c| cnames << Hpricot.XML( Net::HTTP.get( URI.parse( 'http://www.colourlovers.com/api/color/' + c + '?format=xml' ))).at("title").inner_text }
          super colors.map! {|c| [cnames.shift,c] }
        else
          super colors
        end
      end
      
    end
  end
end