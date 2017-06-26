require 'rubyplay_framework'

module Heroe
  class Heroe < MapEntity::Entity
    
    def intialize(type = "", nametag = "", gender = "")
      super(type, nametag)
      @gender = gender
      @bag = []
    end

    attr_accessor :nametag, :gender
    
    def coger(item)
      @bag << item
    end
    
    def coger(cofre)
      cofre.each do |item|
        coger(item)
        cofre.delete_item(item)
      end
    end
    
    def ritual(altar)
      if(@bag.find { |item| item.name == "Libro de Thoth"})
        altar.realizar_ritual
        message = "Ritual completado. En algún lugar se ha abierto una puerta."
      else
        message = "No tienes el objeto necesario"
      end
      return message
    end

    def to_s()
      "Nombre: #{nametag}\nGénero: #{gender}"
    end
    
  end
end