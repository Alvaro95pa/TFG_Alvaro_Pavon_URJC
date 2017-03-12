require 'mapper/map'

class Roleplay_framework
  
  def initialize(fileName)
    @map = Map.load_from_file(fileName)
  end
  
  attr_reader :map
end