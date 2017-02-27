require 'xml/mapping'
require 'mapper/point'

class Map_node
  include XML::Mapping
    
    #Attributes
    #dungeon_node :dungeon, "dungeon" #User will made their own dungeon class
    object_node :point, "point", :class=>Point
    array_node :adjacent, "adjacent", "point", :class=>Point, :default_value=>[]

    #Returns true if point is at adjacent list
    def is_adjacent?(point)
      self.adjacent.find() { |p|
        point == p
      }
    end
    
    #Returns the node after calculating the movement
    def move(moveX, moveY)
      if(self.adjacent != [])
        p = self.point
        p.x = p.x + moveX
        p.y = p.y + moveY
        if(self.is_adjacent?(p))
          p
        else
          raise RuntimeError, "There is not an adjacent node with values (#{p.x},#{p.y})"
        end
      else
        raise RuntimeError, "The node has not adjacent"
      end
    end
end