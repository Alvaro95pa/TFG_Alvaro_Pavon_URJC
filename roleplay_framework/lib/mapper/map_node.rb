require 'mapper/dungeon'
require 'mapper/point'

class Map_node
    
  def initialize(point, dungeon, adjacent)
    @point, @dungeon, @adjacent = point, dungeon, adjacent
  end

  #Returns true if point is at adjacent list
  def is_adjacent?(point)
    @adjacent.find() { |p|
      point == p
    }
  end
    
  #Returns the node after calculating the movement
  def move(moveX, moveY)
    if(@adjacent != [])
      p = @point
      p.x = p.x + moveX
      p.y = p.y + moveY
      if(is_adjacent?(p))
        p
      else
        raise RuntimeError, "There is not an adjacent node with values (#{p.x},#{p.y})"
      end
    else
      raise RuntimeError, "The node has not adjacent"
    end
  end
  
  attr_reader :point, :dungeon, :adjacent
end