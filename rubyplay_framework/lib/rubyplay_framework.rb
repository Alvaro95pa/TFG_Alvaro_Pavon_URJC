require 'map/map'
require 'map/dungeon'
require 'map/entity'
require 'map/point'
require 'map/mapExceptions'
require 'interpreter/gameLexer'
require 'interpreter/gameParser'

module Rubyplay_framework
  include MapPoint, MapDungeon, MapEntity
  
  def init_Map()
    Map.new()
  end
  
  def init_Interpreter()
    GameLanguage.new()
  end
  
end