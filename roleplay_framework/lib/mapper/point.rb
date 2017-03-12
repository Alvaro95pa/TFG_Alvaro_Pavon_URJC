
class Point
  
  def initialize(x, y)
    @x, @y = x, y
  end
  
  #Attributes access
  attr_accessor :x, :y
  
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
  
  #To string
  def to_s
    "(#{x},#{y})"
  end
  
  protected
  
  def state
    [x, y]
  end
  
end