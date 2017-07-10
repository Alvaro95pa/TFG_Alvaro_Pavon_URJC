require 'rubyplay_framework'

  class Heroe < MapEntity::Entity
    
    def intialize(type = "Heroe", nametag = "", genero = "", posicion = nil)
      super(type, nametag)
      @genero = genero
      @mochila = []
      @posicion = posicion
    end
    
    attr_accessor :genero, :posicion

    def avanzar(point)
      @posicion = point
    end
    
    def tomar(item)
      @mochila << item
    end
    
    def tomar_items(cofre)
      cofre.each_item do |item|
        tomar(item)
        cofre.delete_item(item)
      end
    end
    
    def mochila()
      @mochila.each { |item| yield item }
    end
    
    def ejecutar_ritual(altar)
      if(@mochila.find { |item| item.name == "Libro de Thoth"})
        message = "Ritual completado. En algún lugar se ha abierto una puerta."
      else
        message = "No tienes el objeto necesario"
      end
      return message
    end
    
    def activar_elevador(elevador)
      if(@mochila.find { |item| item.nombre == "Ídolo de Anubis" })
        message = "El elevador se ha activado"
      else
        message = "No tienes el objeto necesario"
      end
      return message
    end
    
    def hablar(npc)
    end
    
  end
