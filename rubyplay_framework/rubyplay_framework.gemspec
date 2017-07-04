Gem::Specification.new do |s|
  s.name        = 'rubyplay_framework'
  s.version     = '1.6.5'
  s.add_runtime_dependency "nokogiri", '~>1.6', '>= 1.6.8'
  s.add_runtime_dependency "rexical", '~>1.0', '>= 1.0.5'
  s.add_runtime_dependency "racc", '~>1.4', '>= 1.4.14'
  s.date        = '2017-02-20'
  s.summary     = "Roleplay games development helper library"
  s.description = "A library to ease development of roleplay games for textual enviroments"
  s.authors     = ["Alvaro Pavon Alvarado"]
  s.email       = 'alvaro.pavon.alvarado@gmail.com'
  s.files       = ["lib/rubyplay_framework.rb","lib/map/map.rb","lib/map/dungeon.rb","lib/map/point.rb","lib/map/entity.rb",
  					"lib/map/mapExceptions.rb", "lib/interpreter/gameLexer.rb", "lib/interpreter/gameParser.rb", 
  					"lib/interpreter/gameLexer.rex", "lib/interpreter/gameParser.racc", "lib/map.xsd"]
  s.homepage    =
    'https://github.com/Alvaro95pa/TFG_Alvaro_Pavon_URJC/tree/master'
  s.license       = 'Apache-2.0'
end