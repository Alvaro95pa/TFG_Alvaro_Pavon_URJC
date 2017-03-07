class Dungeon
  
  def initialize(name)
    @name = name
  end
  
  def to_s()
    "#{@name}"
  end
  
  attr_reader :name
end