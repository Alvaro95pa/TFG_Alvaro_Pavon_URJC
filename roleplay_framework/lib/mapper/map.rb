require 'nokogiri'
require 'mapper/map_node'

class Map

  def initialize(file)
    @map = build_nodes(file)
  end
  
  #Attribute access
  attr_reader :map   
  
  #Returns an adjacent point
  def movement(point, despX, despY)
    n = return_node(point)
    newP = n.move(despX, despY)
    return return_node(newP)
  end
  
  #Returns the node with that coordinates
  def return_node(point)
    @map[point]
  end
  
  private
  
  #Parse XML document and returns a String
  def parse_from_XML(file)
    File.open(file) { |f| Nokogiri::XML(f) }
  end
  
  #Builds the hash table with all the nodes
  def build_nodes(file)
    m = Hash.new()
    doc = parse_from_XML(file)
    doc.remove_namespaces!
    doc.xpath("//node").each() { |node|
      point = build_point(node)
      dungeon = build_dungeon(node)
      adjacent = build_adjacent(node)
      n = Map_node.new(point,dungeon,adjacent)
      m[point] = n
    }
    return m
  end   
  
  #Builds the point of a node
  def build_point(node)
    x = node.xpath("point//x/text()").to_s()
    y = node.xpath("point//y/text()").to_s()
    Point.new(x.to_i(), y.to_i())
  end
  
  #Builds the dungeon object of a node
  def build_dungeon(node)
    name = node.xpath("dungeon//name/text()").to_s()
    description = node.xpath("dungeon//description/text()").to_s()
    Dungeon.new(name, description)
  end
  
  #Builds the adjacent list of a node
  def build_adjacent(node)
    adjacent = []
    node.xpath("adjacent//point").each() { |point|
      x = point.xpath("x/text()").to_s()
      y = point.xpath("y/text()").to_s()
      p = Point.new(x.to_i(), y.to_i())
      adjacent << p
    }
    return adjacent
  end
  
end