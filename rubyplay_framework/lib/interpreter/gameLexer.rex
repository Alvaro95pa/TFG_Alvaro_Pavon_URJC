class GameLanguage
macro
  BLANK	[\ \t]+ #only works on macro
  NUMBER \d+|-\d+
  FLOAT \d+\.\d+|-\d+\.\d+
  WORD [\ \t]+[a-z]+|[\ \t]+[A-Z][a-z]+|[\ \t]+[a-z]+\d+|[\ \t]+[A-Z][a-z]+\d+
  FUNCTION \w+
rule
  {WORD}   { [:WORD, text.gsub!(/[\ \t]+/,'')] }
  {BLANK} #do nothing
  {NUMBER} {[:NUMBER, text.to_i]}
  {FLOAT} {[:FLOAT, test.to_f]}
  {FUNCTION} {[:FUNCTION, text]}

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