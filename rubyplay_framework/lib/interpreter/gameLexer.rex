class GameLanguage
macro
  BLANK	[\ \t]+ #only works on macro
  DIGIT \d+
rule
  {BLANK} #do nothing
  [a-z]+_[a-z]+\(\) {[:FUNCTION, text]}
  [a-z]+_[a-z]+ {[:FUNCTION, text]}
  [a-z]+   { [:WORD, text] }
  {DIGIT} {[:DIGIT, text.to_i]}
  
inner
  def tokenize(code)
    scan_setup(code)
    tokens = []
    while token = next_token
      tokens << token
    end
    tokens
  end
end