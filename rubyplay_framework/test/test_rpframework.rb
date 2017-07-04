require 'minitest/autorun'
require 'rubyplay_framework'


class EntityExtended < MapEntity::Entity
  def initialize(type = "", nametag = "", gold = 0)
    super(type, nametag)
    @gold = gold
  end
  
  def to_s()
    super+"\nGold: #{@gold}"
  end
  
  attr_accessor :gold
end

class EntityXPathBuilderExtended < MapEntity::EntityBuilder
  def initialize()
    @entity = EntityExtended.new()
  end
  
  attr_reader :entity
  
  def build_entity(type, nametag, gold)
    super(type, nametag)
    add_gold(gold.to_i)
  end
  
  def add_gold(gold)
    @entity.gold = gold
  end
end

class DungeonExtended < MapDungeon::Dungeon
  def initialize(name = "", description = "", lvl = 0)
    super(name, description)
    @lvl = lvl
  end
  
  attr_accessor :lvl
  
  def to_s()
    super+"\n#{@lvl}"
  end
end

class DungeonXPathBuilderExtended < MapDungeon::DungeonBuilder
  def initialize()
    @dungeon = DungeonExtended.new()
  end
  
  attr_reader :dungeon
  
  def build_dungeon(name, description, lvl, node = nil, entityBuilder = "")
    super(name,description,node,entityBuilder)
    add_lvl(lvl.to_i)
  end
  
  def add_lvl(lvl)
    @dungeon.lvl = lvl
  end
end

class PointExtended < MapPoint::Point
  def initialize(x = 0, y = 0, z = 0, w = 0)
    super(x,y,z)
    @w = w
  end
  
  attr_accessor :w
  
  def to_s()
    "(#{@x},#{@y},#{@z},#{@w})"
  end
  
  protected
    def state
      super << w
    end
end

class PointXPathBuilderExtended < MapPoint::PointBuilder
  def initialize()
    @point = PointExtended.new()
  end
  
  attr_reader :point
  
  #Builds the point of a node
  def build_point(x, y, z, w)
    super(x,y,z)
    add_w(w.to_i)
  end
  
  def add_w(w)
    @point.w = w
  end
end

class Tester
  def sumar(x,y)
    x+y
  end
  
  def say_what(what)
    puts what
  end
  
  private
  def say_hello()
    puts "Hello!"
  end
end

############## TEST #################
class RPTest < Minitest::Test
  include RubyplayFramework
  
  #Test interpreter
  def test_interpreter()
    i = init_Interpreter()
    i.intialize_functions("test/testFile.txt")
    test = Tester.new()
    result = i.parse(test, "sumar -1 2")
    assert(result == 1)
  end
  ### End test ###
  
  #Test exception on file load
  def test_load()
    m = init_Map() 
    assert_raises(MapExceptions::MalformedMapException) {
      m.build_map("test/test2.xml")
    }  
  end
  
  def test_load2()
    m = init_Map()
    #p = PointExtended.new(50,0,0,0)
    m.build_map("test/test3.xml", "PointXPathBuilderExtended", "DungeonXPathBuilderExtended", "EntityXPathBuilderExtended")
    #m.map_nodes[p].each_entity { |e| puts e }
    #m.map_nodes().each { |key, value| puts "#{key} -> #{value}" }
    assert(m.map_nodes != nil)
  end
 
  #Test a correct file load
  def test_mapNotNul()
    m = init_Map()
    m.build_map("test/test1.xml")
    assert(m.map_nodes != nil)
  end
  
  #Test has_entity?
  def test_hasEntity()
    m = init_Map()
    m.build_map("test/test1.xml")
    point =  Point.new(0,0,0)
    entity = Entity.new("Hero", "Keops")
    assert(m.has_entity?(point,entity))
  end
  
  def test_shortestPath()
    m = init_Map()
    m.build_map("test/test1.xml")
    init =  Point.new(1,0,0)
    destination = Point.new(-1,0,0)
    distance = m.shortest_path(init,destination)
    assert(distance == 2)
  end
  
  #Test movements
  def test_movement()
    m = init_Map()
    m.build_map("test/test1.xml")
    point =  Point.new(0,0,0)
    entity = Entity.new("Hero", "Keops")
    m.move(point,entity,1)
    point2 =  Point.new(1,0,0)
    assert(m.has_entity?(point2,entity))
  end
  
  def test_movement2()
    m = init_Map()
    m.build_map("test/test1.xml")
    point =  Point.new(0,0,0)
    entity = Entity.new("Hero", "Keops")
    assert_raises(MapExceptions::NotAdjacentException) {
      m.move(point,entity,50)
    }
  end
  
  #Test add an entity to a node that already has an entity
  def test_addEntity()
    m = init_Map()
    m.build_map("test/test1.xml")
    point =  Point.new(0,0,0)
    entity = Entity.new("Mob", "Psycho")
    m.add_entity(point,entity)
    assert((m.has_entity?(point,entity)))
  end
  
  #Test add entity to a node without other entities
  def test_addEntity2()
    m = init_Map()
    m.build_map("test/test1.xml")
    point =  Point.new(1,0,0)
    entity = Entity.new("Mob", "Psycho")
    m.add_entity(point,entity)
    assert(m.has_entity?(point,entity))
  end
  
  #Test addition/deletion of nodes
  def test_deleteNode()
    m = init_Map()
    m.build_map("test/test1.xml")
    point = Point.new(2,0,1)
    m.delete_node(point)
    #m.adjacencies().each { |key, value| puts "#{key} -> #{value}" }
    assert(m.map_nodes.length == 6)
  end
  
  def test_addNode()
    m = init_Map()
    m.build_map("test/test1.xml")
    d = Dungeon.new("Summit","Una fría cima")
    p = Point.new(2, 0, 0)
    p2 = Point.new(1, 0, 0)
    p3 = Point.new(2, 0, 1)
    ad = [p2, p3]
    m.add_new_node(p,d,ad)
    #m.map_nodes().each { |key, value| puts "#{key} -> #{value}" }
    assert(m.map_nodes.length == 8)
  end
  
  #Test addition/deletion of adjacent
  def test_addAdjacent()
    m = init_Map()
    m.build_map("test/test1.xml")
    p = Point.new(-1, 0, 0)
    lengthBefore = m.adjacencies[p].length
    p2 = Point.new(1, 0, 0)
    m.add_new_adjacent(p,p2)
    lengthAfter = m.adjacencies[p].length
    #m.adjacencies().each { |key, value| puts "#{key} -> #{value}" }
    assert(lengthAfter > lengthBefore)
  end
  
  def test_deleteAdjacent()
    m = init_Map()
    m.build_map("test/test1.xml")
    p = Point.new(2, 0, 1)
    p2 = Point.new(1, 0, 0)
    lengthBefore = m.adjacencies[p2].length
    m.delete_adjacent(p2,p)
    lengthAfter = m.adjacencies[p2].length
    #m.adjacencies().each { |key, value| puts "#{key} -> #{value}" }
    #m.map_nodes().each { |key, value| puts "#{key} -> #{value}" }
    assert(lengthAfter < lengthBefore)
  end
   
  #Get all entities from a node
  def test_eachEntity()
    m = init_Map()
    m.build_map("test/test1.xml")
    point =  Point.new(0,0,0)
    entity = Entity.new("Mob", "Psycho")
    m.add_entity(point,entity)
    count = 0
    m.get_node(point).each_entity { |e| count+=1 }
    assert(count == 2)
  end
 
  #Add new entity extended
  def test_entityExtension()
    e = EntityExtended.new("Chest", "Iron Chest", 20)
    m = init_Map()
    m.build_map("test/test1.xml")
    point =  Point.new(0,0,0)
    m.add_entity(point,e)
    #m.map_nodes[point].each_entity { |e| puts e }
    assert(m.has_entity?(point,e))
  end
  
end
