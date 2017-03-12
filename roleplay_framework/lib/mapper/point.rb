require 'xml/mapping'

class Point
  include XML::Mapping
  
  #Attributes
  numeric_node :x, "x"
  numeric_node :y, "y"
  
  #Returns true if the point has the same x and y values of self
  def same_position?(point)
    ((self.x == point.x) && (self.y == point.y))
  end
  
  #Writes the point
  def to_s
    "(#{x},#{y})"
  end
  
end