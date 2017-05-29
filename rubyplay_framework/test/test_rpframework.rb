require 'minitest/autorun'
require 'rubyplay_framework'
require 'map/entity'

class EntityExtended < MapEntity::Entity
  def initialize(type = "", nametag = "", gold = 0)
    super(type, nametag)
    @gold = gold
  end
  
  def to_s()
    "Name: #{@nametag}\nGold: #{@gold}"
  end
end

class RPTest < Minitest::Test
  include Rubyplay_framework
  
  #Test exception on file load
  def test_load()
    m = init_Map() 
    assert_raises(MapExceptions::MalformedMapException) {
      m.build_map("test/test2.xml")
    }  
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
    m.move(point,entity,1)
    point2 =  Point.new(1,0,0)
    entity2 = Entity.new("Hero", "Keops")
    assert(!(m.has_entity?(point,entity2)))
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
    assert(m.map_nodes.length == 3)
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
    assert(m.map_nodes.length == 5)
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
    p = Point.new(-1, 0, 0)
    lengthBefore = m.adjacencies[p].length
    p2 = Point.new(0, 0, 0)
    m.delete_adjacent(p2,p)
    lengthAfter = m.adjacencies[p].length
    #m.adjacencies().each { |key, value| puts "#{key} -> #{value}" }
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
    m.get_node(point).each_entity { |entity| count+=1 }
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
