require 'rubyplay_framework'
  
  class Npc < MapEntity::Entity
    def initialize(type="", nametag="", posicion = nil)
      super(type, nametag)
      @posicion = posicion
    end

    attr_accessor :posicion
    
    def hablar1(genero)
      texto = ''
      if(genero =~ /Chico/)
        texto = "Encapuchado: \"Vaya, parece que también estás atrapado ¿Yo? Oh, llevo atrapado mucho tiempo, demasiado. Pero podemos ayudarnos mutuamente. Escucha atentamente, necesitarás una reliquia para desbloquear la salida, un viejo libro. Búscame en el altar cuando tengas el libro\""
      else
        texto = "Encapuchado: \"Vaya, parece que también estás atrapada ¿Yo? Oh, llevo atrapado mucho tiempo, demasiado. Pero podemos ayudarnos mutuamente. Escucha atentamente, necesitarás una reliquia para desbloquear la salida, un viejo libro. Búscame en el altar cuando tengas el libro\""
      end
      return texto
    end
    
    def hablar2
      texto = "Encapuchado: \"¡Lo has encontrado! Bien, en ese caso, realicemos el ritual. No te preocupes, no me harás daño. Simplemente me permitirás regresar a mi mundo. Ahora me despido, gracias por liberarme y buena suerte.\""
      return texto
    end
    
  end
