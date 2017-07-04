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
  def build_map(filePath, pointBuilder = "", dungeonBuilder = "", entityBuilder = "")
    if(filePath.include?('http'))
      doc = parse_from_URL(filePath)
    else
      doc = parse_from_XML(filePath)
    end
    doc.remove_namespaces!
    doc.xpath("//node").each() do |node|
      coords = node.xpath("point//*")
      point = build_point(coords, pointBuilder)
      dungeonElements = node.xpath("dungeon//*[not(name()='entity') and not(ancestor-or-self::entity)]")
      dungeon = build_dungeon(node, dungeonElements, dungeonBuilder, entityBuilder)
      @map_nodes[point] = dungeon
      build_adjacent(point, node, pointBuilder)  
    end
    p = @map_nodes.keys().sample() #Get random key
    if(@map_nodes.length() != check_connectivity(p))
      raise MapExceptions::MalformedMapException.new()
    end
  end   
  
  #Allows to make a movement without creating a explicit Point object
  def move(point, entity, movX = 0, movY = 0, movZ = 0)
    toPoint = Point.new(point.x()+movX, point.y()+movY, point.z()+movZ)
    movement(point, toPoint, entity)
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
  def check_connectivity(point, visited = Hash.new())
    visited[point] = 1
    @adjacencies[point].each do |nextPoint|
      if(!visited.has_key?(nextPoint))
        check_connectivity(nextPoint, visited)
      end
    end
    return visited.length()
  end
  
  #Shortest path from initial to destination
  def shortest_path(initial, destination)
    distance = Hash.new()
    visited = Hash.new()
    @adjacencies.each_key do |point|
      if(is_adjacent?(initial, point))
        distance[point] = 1
      else
        distance[point] = (2**(0.size * 8 - 2) - 1)
      end
    end
    visited[initial] = true
    distance.delete(initial)
    until(visited.length == @adjacencies.length) do
      if((value = distance.values.min) != nil)
        if(!(visited.has_key?(distance.key(value))))
          nextNode = distance.key(value)
          visited[nextNode] = true
          if(nextNode == destination)
            break;
          end
          @adjacencies[nextNode].each do |a|
            alt = distance[nextNode] + 1
            if(!(visited.has_key?(a)) && alt < distance[a])
              distance[a] = alt
            end
          end
          distance.delete(nextNode)
        end
      end
    end
    return distance[destination]
  end

protected
  
  #Parse XML document and returns a String
  def parse_from_XML(file)
    File.open(file) { |f| Nokogiri::XML(f) }
  end
  
  #Parse XML from given url
  def parse_from_URL(url)
    Nokogiri::XML(open(url))
  end   
  
  #Builds the point of a node
  def build_point(nodeSet, pointBuilder = "")
    args = []
    if(pointBuilder.length > 0)
      builder = Object::const_get(pointBuilder).new()
    else
      builder = PointBuilder.new()
    end
    nodeSet.each { |node| args << node.content }
    builder.build_point(*(args))
    builder.point()
  end
  
  #Builds the dungeon object of a node
  def build_dungeon(node, nodeSet, dungeonBuilder = "", entityBuilder = "")
    args = []
    if(dungeonBuilder.length > 0)
      builder = Object::const_get(dungeonBuilder).new()
    else
      builder = DungeonBuilder.new()
    end
    nodeSet.each { |n| args << n.content }
    if(!(node.xpath("dungeon//entity").empty?))
      args << node.xpath("dungeon//entity")
      args << entityBuilder
      builder.build_dungeon(*(args))
    else
      builder.build_dungeon(*(args))
    end
    builder.dungeon()
  end

  #Builds the adjacent list of a node
  def build_adjacent(point, node, pointBuilder = nil)
    node.xpath("adjacent//point").each() { |pnt|
      coords = pnt.xpath(".//*")
      p = build_point(coords, pointBuilder)
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