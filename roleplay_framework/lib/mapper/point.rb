require 'xml/mapping'

class Point
  include XML::Mapping
  
  #Attributes
  numeric_node :x, "x"
  numeric_node :y, "y"
  
  #Redefinition of equal operator
  def ==(other)
    (self.class ==other.class) && (self.state == other.state)
  end
  
  #Use Point == for eql? method
  alias_method :eql?, :==
  
  #It allows to use Point as a hash key
  def hash
    state.hash
  end
  
  #Writes the point
  def to_s
    "(#{x},#{y})"
  end
  
  protected
  
  def state
    [x, y]
  end
  
end