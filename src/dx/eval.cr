require "./abs"

module DX
  class Eval
    @env : Hash(::String, Int32 | ::String)

    def initialize
      @env = Hash(::String, Int32 | ::String).new
    end

    def exec(stm)
      case stm
      when Definition then ""
      when Assign
        x = eval(stm.value)
        if @env.has_key?(stm.name)
          raise "#{stm.name} defined (#{@env[stm.name]})"
        else
          @env[stm.name] = x
        end
      when Print
        puts eval(stm.exp)
      when Comment
      else
        raise "Unknown stm: #{stm} in exec"
      end
    end

    def print_env
      puts @env
    end

    def eval(value : Exp) : Int32 | ::String
      case value
      when ID
        if @env.has_key?(value.id)
          @env[value.id]
        else
          raise "Undefined var #{value.id}"
        end
      when Integer then value.int
      when Neg     then -ensure_int_or_id(eval(value.neg))
      when Plus    then ensure_int_or_id(eval(value.e1)) + ensure_int_or_id(eval(value.e2))
      when Minus   then ensure_int_or_id(eval(value.e1)) - ensure_int_or_id(eval(value.e2))
      when String  then value.exp
      else              raise "Evaluation not found to #{value}"
      end
    end

    def ensure_int_or_id(value)
      result = case value
               when Int32
                 value
               else
                 raise("#{value} should be integer")
               end
      return result
    end
  end
end
