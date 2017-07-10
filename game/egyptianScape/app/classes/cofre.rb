require 'rubyplay_framework'

module Cofre
  
  class Cofre < MapEntity::Entity
    
    def initialize(type = "", nametag = "")
      super(type, nametag)
      @items = []
    end
    
    def add_item(item)
      @items << item
    end
    
    def each_item()
      @items.each { |item| yield item }
    end
    
    def to_s()
      "#{nametag}"
    end
    
  end
  
  class CofreBuilder < MapEntity::EntityBuilder
    
    def initialize()
      @entity = Cofre.new()
    end
    
    def build_entity(type, nametag, *items)
      super(type, nametag)
      add_items(items)
    end
    
    def add_items(items)
      items.each { |item| @entity.add_item(item) }
    end
    
  end
  
end