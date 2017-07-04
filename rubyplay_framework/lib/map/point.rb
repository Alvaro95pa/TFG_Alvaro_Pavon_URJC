module MapPoint
  
  class Point
    
    def initialize(x = 0, y = 0, z = 0)
      @x, @y, @z = x, y, z
    end
    
    #Attributes access
    attr_accessor :x, :y, :z
    
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
      "(#{@x},#{@y},#{@z})"
    end
    
  protected
    
    def state
      [x, y, z]
    end
    
  end
  
  #Point builder class
  class PointBuilder
    
    def initialize()
      @point = Point.new()
    end
    
    attr_reader :point
    
    #Builds the point of a node
    def build_point(x, y, z)
      add_x(x.to_i)
      add_y(y.to_i)
      add_z(z.to_i)
    end
    
    def add_x(x)
      @point.x = x
    end
    
    def add_y(y)
      @point.y = y
    end
    
    def add_z(z)
      @point.z = z
    end
    
  end
end