module DX
  class Exp
    def id
      to_s
    end
  end

  class Definition < Exp
    @name : Exp
    @type : ::String

    getter :name, :type

    def initialize(@name, @type)
    end

    def name
      @name.id
    end

    def to_s(io)
      io << "<Definition name=#{@name} type=#{@type}>"
    end
  end

  class Assign < Exp
    @name : Exp
    @value : Exp

    getter :value

    def initialize(@name, @value)
    end

    def name
      @name.id
    end

    def to_s(io)
      io << "<Assign name=#{@name} value=#{@value}>"
    end
  end

  class Integer < Exp
    @int : Int32

    getter :int

    def initialize(int)
      @int = int
    end

    def to_s(io)
      io << "<Integer int=#{@int}>"
    end
  end

  class ID < Exp
    @id : ::String

    getter :id

    def initialize(@id)
    end

    def to_s(io)
      io << "<ID id=#{@id}>"
    end
  end

  class Neg < Exp
    @neg : Exp

    getter :neg

    def initialize(@neg)
    end

    def to_s(io)
      io << "<Neg neg=#{@neg}>"
    end
  end

  class Plus < Exp
    @e1 : Exp
    @e2 : Exp

    getter :e1, :e2

    def initialize(@e1, @e2)
    end

    def to_s(io)
      io << "<Plus e1=#{@e1} e2=#{@e2}>"
    end
  end

  class Multi < Exp
    @e1 : Exp
    @e2 : Exp

    getter :e1, :e2

    def initialize(@e1, @e2)
    end

    def to_s(io)
      io << "<Multi e1=#{@e1} e2=#{@e2}>"
    end
  end

  class Minus < Exp
    @e1 : Exp
    @e2 : Exp

    getter :e1, :e2

    def initialize(@e1, @e2)
    end

    def to_s(io)
      io << "<Minus e1=#{@e1} e2=#{@e2}>"
    end
  end

  class Print
    @exp : Exp

    getter :exp

    def initialize(@exp)
    end

    def to_s(io)
      io << "<Print exp=#{@exp}>"
    end
  end

  class Comment
    def to_s(io)
      io << "<Comment>"
    end
  end

  class String < Exp
    @exp : ::String

    getter :exp

    def initialize(@exp)
    end

    def to_s(io)
      io << "<String exp=#{@exp}>"
    end
  end

  class DefFunc < Exp
    @arguments : Array(::String)
    @body : ::String

    getter :body, :arguments

    def initialize(@arguments, @body)
    end
  end

  class CallFunc < Exp
    @arguments : Array(::String)
    @name : ::String

    getter :name, :arguments

    def initialize(@name, @arguments)
    end
  end
end
