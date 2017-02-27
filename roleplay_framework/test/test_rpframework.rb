require 'minitest/autorun'
require 'roleplay_framework'

class RPTest < Minitest::Test
  include Roleplay_framework
  
  def test_load()
    assert_raises(SystemCallError) {
      init_Map("test/test1.xml") 
    }  
  end
  
  def test_writePoint()
    m = init_Map("test/test1.xml") 
    p = m.map["(0,0)"].point
    assert(p != nil)
  end
  
  def test_movement()
      m = init_Map("test/test1.xml") 
      node = m.map["(0,0)"]
      assert_raises(RuntimeError) {
        node.move(1, 1) 
      }   
  end
  
end
