module MapEntity
  
  class Entity
    
    def initialize(type = "", nametag = "")
      @type, @nametag = type, nametag
    end
    
    #Attributes access
    attr_accessor :type, :nametag
    
    #Redefinition of equal operator
    def ==(other)
      (self.class ==other.class) && (self.state == other.state)
    end
    
    def to_s()
      "Type: #{@type}\nName: #{@nametag}"
    end
    
    #Use Entity == for eql? method
    alias_method :eql?, :==
    
  protected
      
    def state
      [type, nametag]
    end
      
  end
  
  #Entity builder class
  class EntityBuilder
    
    def initialize()
      @entity = Entity.new()
    end
    
    attr_reader :entity
    
    #Builds the entity of a dungeon
    def build_entity(type, nametag)
      add_type(type)
      add_nametag(nametag)
    end
    
    def add_type(type)
      @entity.type = type
    end
    
    def add_nametag(nametag)
      @entity.nametag = nametag
    end
    
  end
  
end