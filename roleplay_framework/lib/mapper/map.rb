require 'xml/mapping'
require 'mapper/map_node'

class Map
  include XML::Mapping
  
  #Attributes
  hash_node :map, "node", "@point", :class=>Map_node
    

  
end