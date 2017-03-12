require 'xml/mapping'
require 'point'

class Map_node
  include XML::Mapping
    
    #Attributes
    dungeon_node :dungeon, "dungeon" #User will made their own dungeon class
    object_node :point, "point", :class=>Point
    array_node :adjacent, "adjacent", "point", :class=>Point, :default_value=>[]

    #Returns true if point is adjacent to self
    def is_adjacent?(point)
      self.adjacent.find() { |p|
        point.same_position?(p)
      }
    end
end