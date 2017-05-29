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
  class DungeonXPathBuilder
    include MapEntity
    
    def initialize()
      @dungeon = Dungeon.new()
    end
    
    attr_reader :dungeon
    
    def build_XML_dungeon(node, namePath, descriptionPath, entitiesPath = "")
      add_name(node.xpath("#{namePath}/text()").to_s)
      add_description(node.xpath("#{descriptionPath}/text()").to_s)
      if(entitiesPath.length > 0)
        node.xpath(entitiesPath).each() { |entity|
          entityBuilder = EntityXPathBuilder.new()
          entityBuilder.build_XML_entity(entity, "type", "nametag")
          @dungeon.add_entity(entityBuilder.entity, entityBuilder.entity.type)
        }
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