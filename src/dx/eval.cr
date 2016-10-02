require "./abs"

module DX
  class Env
    getter :data

    def initialize
      @data = Hash(::String, Hash(Symbol, Int32 | ::String | NamedTuple(body: ::String, arguments: Array(::String)))).new
    end

    def allocated?(key)
      @data.has_key?(key)
    end

    def definied?(key)
      @data[key].has_key?(:value)
    end

    def get(key)
      @data[key][:value]
    end

    def set_value(key, value)
      @data[key][:value] = value
    end

    def set_definition(key, kind)
      @data[key] = Hash(Symbol, Int32 | ::String | NamedTuple(body: ::String, arguments: Array(::String))).new
      @data[key][:kind] = kind
    end
  end

  class Eval
    @env : Env

    def initialize
      @env = Env.new
    end

    def exec(stm)
      case stm
      when Definition
        @env.set_definition(stm.name, stm.type)
      when Assign
        x = eval(stm.value)
        if @env.allocated?(stm.name)
          if @env.definied?(stm.name)
            raise "You are trying assign a value to '#{stm.name}' again"
          else
            @env.set_value(stm.name, x)
          end
        else
          raise "Parse Error: #{stm.name} with type definition\ntry to:\n\t#{stm.name} :: #{stm.value.class.to_s.split("::").last}\n"
        end
      when Print
        puts eval(stm.exp)
      when Comment
      when Plus
        eval(stm)
      else
        raise "Unknown stm: #{stm} in exec"
      end
    end

    def print_env
      puts @env.data.to_s
    end

    def eval(value : Exp) : Int32 | ::String | NamedTuple(body: ::String, arguments: Array(::String))
      case value
      when ID
        @env.get(value.id)
      when Integer then value.int
      when Neg     then -ensure_int_or_id(eval(value.neg))
      when Plus    then ensure_int_or_id(eval(value.e1)) + ensure_int_or_id(eval(value.e2))
      when Multi   then ensure_int_or_id(eval(value.e1)) * ensure_int_or_id(eval(value.e2))
      when Minus   then ensure_int_or_id(eval(value.e1)) - ensure_int_or_id(eval(value.e2))
      when String  then value.exp
      when DefFunc then NamedTuple.new(body: value.body, arguments: value.arguments)
      when CallFunc
        func = @env.get(value.name)
        if func.is_a?(NamedTuple)
          e = Eval.new
          p = Parser.new
          body = assigns(Hash.zip(func[:arguments], value.arguments))
          body.push func[:body]

          stms = p.parse(body)

          result = ""
          stms.each do |a|
            result = e.exec(a)
          end

          if result.is_a?(Nil)
            raise "Error: Function"
          end

          return result
        end
        raise "Error: Function"
      else raise "Evaluation not found to #{value}"
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

    def assigns(a)
      p = Parser.new
      a.map do |k, v|
        type_def, var_name = deftype(k)
        ["#{type_def}", "#{var_name.strip} = #{v.strip}"]
      end.flatten
    end

    def deftype(k)
      [k.strip, k.split("::")[0].strip]
    end
  end
end
