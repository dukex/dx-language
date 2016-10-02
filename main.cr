require "./src/dx"

code = ARGF.gets_to_end

def preprocess(data : String)
  data.split("\n").reject(&.empty?)
end

p = DX::Parser.new
stms = p.parse preprocess(code)

# puts "Parsed:\n#{stms.join("\n")}"
# puts "\n"

e = DX::Eval.new

stms.each do |stm|
  e.exec(stm)
end

# e.print_env
