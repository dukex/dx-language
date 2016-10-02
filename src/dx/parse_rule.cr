module DX
  class ParseRule
    @name : ::String
    @rule : Regex

    def initialize(@name, @rule)
    end

    def name
      @name
    end

    def match(code)
      code.match(@rule)
    end
  end
end
