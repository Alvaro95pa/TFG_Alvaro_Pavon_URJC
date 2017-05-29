require 'map/map'
require 'map/dungeon'
require 'map/entity'
require 'map/point'
require 'map/mapExceptions'

module Rubyplay_framework
  include MapPoint, MapDungeon, MapEntity
  
  def init_Map()
    Map.new()
  end
  
  def init_Interpreter()
  end
  
end