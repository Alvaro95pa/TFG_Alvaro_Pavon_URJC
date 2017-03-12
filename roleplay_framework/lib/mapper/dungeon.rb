class Dungeon
  
  def initialize(name, description)
    @name, @description = name, description
  end
  
  #Attributes access
  attr_reader :name, :description
  
  #To string
  def to_s()
    "#{@name}: #{@description}"
  end
  
end