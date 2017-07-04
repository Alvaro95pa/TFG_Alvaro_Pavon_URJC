require 'nokogiri'
require 'map/entity'

module MapDungeon

  class Dungeon
    
    def initialize(name = "", description = "")
      @name, @description = name, description
      @entities = Hash.new()
    end
    
    #Attributes access
    attr_accessor :name, :description
    
    #Add entities to the hash
    def add_entity(entity, type)
      if(@entities[type] == nil)
        @entities[type] = [entity]
      else
        @entities[type] << entity
      end
    end
    
    #Remove the entity from the array
    def remove_entity(entity, type)
      @entities[type].delete(entity)
    end
    
    #Returns true if the entity exists
    def has_entity?(entity, type)
      @entities[type].find { |e| entity.eql?(e) }  
    end
      
    #Entity iterator
    def each_entity()
      @entities.each { |key, value|
        value.each { |entity| yield entity }
      }
    end
    
    #Concrete entity iterator
    def each_type_entity(type)
      @entities[type].each { |entity| yield entity }
    end
    
    #To string
    def to_s()
      "#{@name}: #{@description}"
    end
    
  end
  
  #Dungeon builder class
  class DungeonBuilder
    include MapEntity
    
    def initialize()
      @dungeon = Dungeon.new()
    end
    
    attr_reader :dungeon
    
    def build_dungeon(name, description, node = nil, entityBuilder = "")
      add_name(name)
      add_description(description)
      if(node != nil)
        node.each() do |entity|
          args = []
          if(entityBuilder.length > 0)
            builder = Object::const_get(entityBuilder).new()
          else
            builder = EntityBuilder.new()
          end
          nodeSet = entity.xpath("*")
          nodeSet.each { |n| args << n.content }
          builder.build_entity(*(args))
          @dungeon.add_entity(builder.entity, builder.entity.type)
        end
      end
    end
    
    def add_name(name)
      @dungeon.name = name
    end
    
    def add_description(description)
      @dungeon.description = description
    end
    
  end
  
end