require 'xml/mapping'
require 'map_node'

class Map
  include XML::Mapping
  
  #Attributes
  hash_node :map, "node", "@point", :class=>map_node
    
  #Returns the node after calculating the movement
  def move(node, moveX, moveY)
    if(node.adjacent != [])
      #Calculate movement
    end
  end
  
end