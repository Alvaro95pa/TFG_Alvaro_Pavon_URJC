require 'rubyplay_framework'

  class Heroe < MapEntity::Entity
    
    def intialize(type = "Heroe", nametag = "", genero = "", mochila = [], posicion = nil)
      super(type, nametag)
      @genero = genero
      @mochila = mochila
      @posicion = posicion
    end
    
    attr_accessor :genero, :posicion, :mochila
    
    def tomar(item)
      @mochila << item
    end
    
    def tomar_items(cofre)
      cofre.each_item do |item|
        tomar(item)
      end
    end

  end
