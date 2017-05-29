require 'nokogiri'
require 'map/point'
require 'map/dungeon'
require 'map/entity'
require 'map/mapExceptions'

class Map
  
include MapPoint, MapDungeon, MapEntity

  def initialize()
    @map_nodes = Hash.new()
    @adjacencies = Hash.new()
  end
  
  #Attribute access
  attr_reader :map_nodes, :adjacencies
  
  #Builds the map structure from XML specification
  def build_map(file, url = false)
    if(url)
      doc = parse_from_URL(file)
    else
      doc = parse_from_XML(file)
    end
    doc.remove_namespaces!
    doc.xpath("//node").each() { |node|
      point = build_point(node, "point//x", "point//y", "point//z")
      dungeon = build_dungeon(node)
      @map_nodes[point] = dungeon
      build_adjacent(point, node)
    }
    p = @map_nodes.keys().sample() #Get random key
    if(@map_nodes.length() != check_connectivity(p, visited = []))
      raise MapExceptions::MalformedMapException.new()
    end
  end   
  
  #Puts move the entity from one point to an adjacent
  def movement(fromPoint, toPoint, entity)
    if(is_adjacent?(fromPoint, toPoint))
        remove_entity(fromPoint, entity)
        add_entity(toPoint, entity)
    else
      raise MapExceptions::NotAdjacentException.new(fromPoint,toPoint)
    end
  end
  
  #Allows to make a movement without creating a explicit Point object
  def move(point, entity, movX = 0, movY = 0, movZ = 0)
    toPoint = Point.new(point.x()+movX, point.y()+movY, point.z()+movZ)
    movement(point, toPoint, entity)
  end
  
  #Check if point2 is in the adjacent list of point1
  def is_adjacent?(point1, point2)
    @adjacencies[point1].find { |p| point2 == p }  
  end
  
  #Returns the node with that coordinates
  def get_node(point)
    @map_nodes[point]
  end
  
  #Iterates over the adjacency hash
  def each_adjacency()
    @adjacencies.each { |key, value|
      value.each { |adjacent| yield adjacent }
    }
  end
  
  #Allows user to add a new node after building the map
  def add_new_node(point, node, adjacencies = [])
    @map_nodes[point] = node
    @adjacencies[point] = adjacencies
    adjacencies.each do |p| 
      if((@adjacencies[p] != nil) && !(is_adjacent?(p, point)))
        @adjacencies[p] << point
      end
    end
  end
  
  #Allows user to delete a node of the map
  def delete_node(point)
    @map_nodes.delete(point)
    @adjacencies.delete(point)
    @adjacencies.each { |k, v| @adjacencies[k].delete(point) }
  end
  
  #Adds a new adjacent to point only if it belongs to the map
  def add_new_adjacent(point, newAdjacent)
    if((@map_nodes[point] != nil) && !(is_adjacent?(point, newAdjacent)) && (@map_nodes[newAdjacent] != nil))
      @adjacencies[point] << newAdjacent
      @adjacencies[newAdjacent] << point
    end 
  end
  
  #Delete a single element from the adjacent list of point
  def delete_adjacent(point, adjacent)
    @adjacencies[point].delete(adjacent)
    @adjacencies[adjacent].delete(point)
  end
  
  #Adds a new entity to the node
  def add_entity(point, entity)
    @map_nodes[point].add_entity(entity, entity.type())
  end
  
  #Removes an entity
  def remove_entity(point, entity)
    @map_nodes[point].remove_entity(entity, entity.type())
  end
  
  #Checks if there is an entity on the node
  def has_entity?(point, entity)
    @map_nodes[point].has_entity?(entity, entity.type())
  end
  
  #Checks if the map generated is fully connected
  def check_connectivity(point, visited = [])
    visited << point
    @adjacencies[point].each { |nextPoint|
      if(!visited.find {|vPoint| vPoint == nextPoint})
        check_connectivity(nextPoint, visited)
      end
    }
    return visited.length()
  end
  
protected
  
  #Parse XML document and returns a String
  def parse_from_XML(file)
    File.open(file) { |f| Nokogiri::XML(f) }
  end
  
  #Parse XML from given url
  def parse_from_URL(url)
    doc = Nokogiri::XML(open(url))
  end   
  
  #Builds the point of a node
  def build_point(node, xPath, yPath, zPath)
    pointBuilder = PointXPathBuilder.new()
    pointBuilder.build_XML_point(node, xPath, yPath, zPath)
    pointBuilder.point()
  end
  
  #Builds the dungeon object of a node
  def build_dungeon(node)
    if(node.xpath("dungeon//entity"))
      dungeonBuilder = DungeonXPathBuilder.new()
      dungeonBuilder.build_XML_dungeon(node, "dungeon//name", "dungeon//description", "dungeon//entity")
    else
      dungeonBuilder = DungeonXPathBuilder.new()
      dungeonBuilder.build_XML_dungeon(node, "dungeon//name", "dungeon//description")
    end
    dungeonBuilder.dungeon()
  end

  #Builds the adjacent list of a node
  def build_adjacent(point, node)
    node.xpath("adjacent//point").each() { |pnt|
      p = build_point(pnt, "x", "y", "z")
      if(@adjacencies[point] == nil)
        @adjacencies[point] = [p]
      elsif(!(is_adjacent?(point, p)))
        @adjacencies[point] << p
      end
      if(@adjacencies[p] == nil)
        @adjacencies[p] = [point]
      elsif(!(is_adjacent?(p, point)))
        @adjacencies[p] << point
      end
    }
  end
  
end