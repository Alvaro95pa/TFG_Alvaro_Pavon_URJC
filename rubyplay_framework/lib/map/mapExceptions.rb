module MapExceptions
  
  class MalformedMapException < StandardError
     
    def initialize(msg="The given map is not fully connected")
      super
      end
     
  end
   
  class NotAdjacentException < StandardError
     
    def initialize(pointIni, pointFin)
      msg = "Point #{pointFin} is not an adjacent point of #{pointIni}"
      super(msg)
    end
     
  end
 
end