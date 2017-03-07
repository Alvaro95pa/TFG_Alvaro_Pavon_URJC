require 'minitest/autorun'
require 'roleplay_framework'

class RPTest < Minitest::Test
  include Roleplay_framework
  
  #Test exception on file load
  def test_load()
    assert_raises(SystemCallError) {
      init_Map("test/asdawdq.xml") 
    }  
  end
  
  #Test a correct file load
  def test_mapNotNul()
    m = init_Map("test/test1.xml")
    assert(m.map != nil)
  end
  
  #Test if the object it is not nul
  def test_point()
    m = init_Map("test/test1.xml")
    punto = Point.new(1,0)
    result = m.map[punto].point
    assert(result != nil)
  end
  
  #Test if the object it is not nul
  def test_dungeon()
    m = init_Map("test/test1.xml")
    punto = Point.new(1,0)
    result = m.map[punto].dungeon
    assert(result != nil)
  end
  
  #Test if the array is not empty
  def test_adjacent()
    m = init_Map("test/test1.xml")
    punto = Point.new(0,0)
    result = m.map[punto].adjacent
    assert(result != [])
  end
  
  #Test if a node has any adjacent
  def test_is_adjacent()
    m = init_Map("test/test1.xml")
    p = Point.new(0,0)
    n = m.map[p]
    p2 = Point.new(1,0)
    assert(n.is_adjacent?(p2))
  end
  
  #Test if the movement returns a node
  def test_movement()
      m = init_Map("test/test1.xml")
      punto = Point.new(0,0)
      node = m.map[punto]
      assert_raises(RuntimeError) {
        node.move(1,0) 
      }   
  end

end
