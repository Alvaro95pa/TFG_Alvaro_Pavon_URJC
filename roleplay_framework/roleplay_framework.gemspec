Gem::Specification.new do |s|
  s.name        = 'roleplay_framework'
  s.version     = '1.1.2'
  s.add_runtime_dependency "nokogiri", ["= 1.6.8"]
  s.date        = '2017-02-20'
  s.summary     = "Roleplay games library"
  s.description = "A library to ease development of roleplay games"
  s.authors     = ["Alvaro Pavon"]
  s.email       = 'alvaro.pavon.alvarado@gmail.com'
  s.files       = ["lib/roleplay_framework.rb","lib/mapper/map.rb","lib/mapper/map_node.rb","lib/mapper/dungeon.rb","lib/mapper/point.rb"]
end