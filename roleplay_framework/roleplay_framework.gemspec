Gem::Specification.new do |s|
  s.name        = 'roleplay_framework'
  s.version     = '0.0.0'
  add_runtime_dependency "xml-mapping", ["= 0.10.0"]
  s.date        = '2017-02-20'
  s.summary     = "Roleplay games library"
  s.description = "A library to ease development of roleplay games"
  s.authors     = ["Alvaro Pavon"]
  s.email       = 'alvaro.pavon.alvarado@gmail.com'
  s.files       = ["lib/mapper/point.rb","lib/mapper/map_node.rb","lib/mapper/map.rb"]
end
