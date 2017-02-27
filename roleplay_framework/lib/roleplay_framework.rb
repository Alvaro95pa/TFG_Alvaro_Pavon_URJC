require 'mapper/map'

module Roleplay_framework
  
  def init_Map(filename)
    Map.load_from_file(filename)
  end
  
end