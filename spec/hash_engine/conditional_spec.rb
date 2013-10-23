require 'hash_engine'

describe HashEngine do
  describe 'conditional operations' do
    # left_op       right_op     operation              expected
    [[1,            2,           'ne',                  true],
     [1,            1,           'ne',                  false],
     [1,            1,           'eq',                  true],
     [1,            2,           'eq',                  false],
     [1,            2,           'lt',                  true],
     [1,            1,           'lt',                  false],
     [2,            1,           'gt',                  true],
     [1,            1,           'gt',                  false],
     [1,            2,           'lteq',                true],
     [1,            1,           'lteq',                true],
     [2,            1,           'lteq',                false],
     [2,            1,           'gteq',                true],
     [2,            2,           'gteq',                true],
     [1,            2,           'gteq',                false],
     [1,            '',          'exist',               true],
     [nil,          '',          'exist',               false],
    ].each {|left_operand, right_operand, operation, expected|
      it "#{left_operand.inspect} #{operation} #{right_operand.inspect} should be #{expected}" do
        HashEngine.conditional(operation, left_operand, right_operand).should == expected
      end
    }
  end
end
