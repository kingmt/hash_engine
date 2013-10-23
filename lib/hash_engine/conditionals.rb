module HashEngine
  module Conditionals

    @@conditionals = {}

    def conditionals
      @@conditionals
    end

    def add_conditional name, &block
      @@conditionals[name] = block
    end

    def valid_conditional?(conditional)
      conditionals.has_key?(conditional)
    end

    def conditional(type, left_operand, right_operand)
      if valid_conditional?(type)
        conditionals[type].call(left_operand, right_operand)
      end
    end

    @@conditionals['ne'] = Proc.new {|left, right| left != right }
    @@conditionals['eq'] = Proc.new {|left, right| left == right }
    @@conditionals['lt'] = Proc.new {|left, right| left < right }
    @@conditionals['gt'] = Proc.new {|left, right| left > right }
    @@conditionals['lteq'] = Proc.new {|left, right| left <= right }
    @@conditionals['gteq'] = Proc.new {|left, right| left >= right }
    @@conditionals['exist'] = Proc.new {|left, right| !!left }
  end
end
