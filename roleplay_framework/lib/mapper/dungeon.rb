class Dungeon
  
  def initialize(name)
    @name = name
  end
  
  #Attributes access
  attr_reader :name
  
  #To string
  def to_s()
    "#{@name}"
  end
  
end