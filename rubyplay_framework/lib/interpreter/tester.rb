require_relative 'gameParser.rb'

class Tester
  
  def suma_r(x,y)
    x+y
  end
  
  def say_what(what)
    puts what
  end
  
  private
  def say_hello()
    puts "Hello!"
  end
  
end

test = Tester.new()
evaluator = GameLanguage.new()
result = evaluator.parse(test, "suma_r() 1 2")
puts result