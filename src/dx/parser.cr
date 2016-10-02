require "./parse_rule"
require "./abs"

module DX
  class Parser
    def initialize
      id = /([a-z][0-9A-Za-z]*)/
      typ = /([A-Z][0-9A-Za-z]*)/
      int = /([0-9]+)/
      expr = /(.*)/
      string = /"(.+)"/
      func_def = /func/
      func_call = /(\w) (.+)/

      @parse_patterns = [
        {name: "Vardef", regex: [id, / :: /, typ]},
        {name: "Assign", regex: [id, / = /, expr]},

        {name: "Type", regex: [typ]},

        {name: "Id", regex: [id]},

        {name: "DefFunc", regex: [func_def, /\((.+)\) -> /, /(.*)/]},

        {name: "Int", regex: [int]},
        {name: "String", regex: [string]},
        {name: "Plus", regex: [expr, / \+ /, expr]},
        {name: "Minus", regex: [expr, / - /, expr]},
        {name: "Neg", regex: [/-/, expr]},
        {name: "Multi", regex: [expr, / \* /, expr]},

        {name: "CallFunc", regex: [func_call]},

        {name: "Print", regex: [/print /, expr]},

        {name: "Comment", regex: [/#/, expr]},

      ]

      @rules = [] of ParseRule

      @parse_patterns.map do |pattern|
        name = pattern[:name]
        regex = "^"
        pattern[:regex].each do |part|
          regex += part.to_s
        end
        regex += "$"
        @rules.push ParseRule.new name, Regex.new(regex)
      end
    end

    def parse(lines : Array(::String))
      lines.map do |line|
        parse_stm(line)
      end
    end

    private def parse_stm(line : ::String)
      @rules.each do |rule|
        matched = rule.match(line)
        if matched
          result = case rule.name
                   when "Vardef"  then definition(matched)
                   when "Assign"  then assign(matched)
                   when "Print"   then print(matched)
                   when "Comment" then comment(matched)
                   when "Plus"    then plus(matched)
                   else
                     raise "Parse Error: stm rule '#{rule.name}' not implemented"
                   end

          return result
        end
      end

      raise "Parse Error: statement not found '#{line}' in rules"
    end

    private def parse_expr(s)
      @rules.each do |rule|
        matched = rule.match(s)
        if matched
          result = case rule.name
                   when "Id"       then id(matched)
                   when "Int"      then int(matched)
                   when "Neg"      then neg(matched)
                   when "Plus"     then plus(matched)
                   when "Minus"    then minus(matched)
                   when "Multi"    then multi(matched)
                   when "String"   then string(matched)
                   when "DefFunc"  then deffunc(matched)
                   when "CallFunc" then callfunc(matched)
                   else
                     raise "Parse Error: expr rule '#{rule.name}' not implemented"
                   end
          return result
        end
      end
      raise "Parse Error: expression not found '#{s}' in rules"
    end

    private def definition(cap : Regex::MatchData)
      e = parse_expr cap[1]
      t = cap[2]
      Definition.new(e, t)
    end

    private def comment(cap)
      Comment.new
    end

    private def assign(cap : Regex::MatchData)
      e1 = parse_expr cap[1]
      e2 = parse_expr cap[2]
      Assign.new e1, e2
    end

    private def print(cap : Regex::MatchData)
      Print.new parse_expr(cap[1])
    end

    private def id(s)
      ID.new s[1]
    end

    private def int(s)
      Integer.new(Int32.new(s[1]))
    end

    private def deffunc(cap)
      arguments = cap[1].split(",")
      body = cap[2]
      DefFunc.new arguments, body
    end

    private def callfunc(cap)
      name = cap[1]
      arguments = cap[2].split(",")
      CallFunc.new name, arguments
    end

    private def neg(cap)
      e = parse_expr cap[1]
      Neg.new e
    end

    private def plus(cap)
      e1 = parse_expr cap[1]
      e2 = parse_expr cap[2]
      Plus.new e1, e2
    end

    private def multi(cap)
      e1 = parse_expr cap[1]
      e2 = parse_expr cap[2]
      Multi.new e1, e2
    end

    private def minus(cap)
      e1 = parse_expr cap[1]
      e2 = parse_expr cap[2]
      Minus.new e1, e2
    end

    private def string(cap)
      e1 = cap[1]
      String.new e1.to_s
    end
  end
end
