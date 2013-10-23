# encoding: utf-8
require 'hash_engine'

describe HashEngine do
  describe 'valid_action?' do
    it 'returns true when key exists' do
      HashEngine.valid_action?('first_value').should be_true
    end

    it 'returns false when key does not exist' do
      HashEngine.valid_action?('foo').should be_false
    end
  end

  describe 'action' do
    describe 'of type: proc' do
      describe 'with data as an array' do
        it 'returns nil when there is a nil in the data' do
          HashEngine.action('proc', 'proc {|x, y| x[1..3]}', [nil, :key1]).should == nil
        end

        it 'returns the result of the proc' do
          my_proc = Proc.new {|x| x[0..2]}
          HashEngine.action('proc', my_proc, ['foobar']).should == 'foo'
        end

        it 'returns the result of the string evaluated to be a proc' do
          HashEngine.action('proc', 'proc {|x| x[0..2]}', ['foobar']).should == 'foo'
        end
      end

      describe 'with data as a single value' do
        it 'returns nil when there is a nil in the data' do
          HashEngine.action('proc', 'proc {|x, y| x[1..3]}', nil).should == nil
        end

        it 'returns the result of the proc' do
          my_proc = Proc.new {|x| x[0..2]}
          HashEngine.action('proc', my_proc, 'foobar').should == 'foo'
        end

        it 'returns the result of the string evaluated to be a proc' do
          HashEngine.action('proc', 'proc {|x| x[0..2]}', 'foobar').should == 'foo'
        end
      end
    end

    describe 'of type: unprotected_proc' do
      describe 'with data as an array' do
        it 'returns the result of the proc' do
          my_proc = Proc.new {|x| x.nil? ? "nil" : x}
          HashEngine.action('unprotected_proc', my_proc, [nil]).should == 'nil'
          my_proc = Proc.new {|x, y| x.nil? ? "nil" : x}
          HashEngine.action('unprotected_proc', my_proc, [nil, :key1]).should == 'nil'
        end

        it 'returns the result of the string evaluated to be a proc' do
          HashEngine.action('unprotected_proc', 'proc {|x, y| x.nil? ? "nil" : x}', [nil, :key1]).should == 'nil'
          HashEngine.action('proc', 'proc {|x| x[1..3]}', ['1234567']).should == '234'
        end
      end
    end

    describe 'of type: lookup_map' do
      it 'returns the lookup value' do
        action_data = {:key1 => :value1,
                       :key2 => :value2}
        HashEngine.action('lookup_map', action_data, :key1).should == :value1
      end

      it 'returns nil on a miss' do
        action_data = {:key1 => :value1,
                       :key2 => :value2}
        HashEngine.action('lookup_map', action_data, :key3).should == nil
      end

      it 'returns the literal default on a miss' do
        action_data = {:key1 => :value1,
                       :key2 => :value2,
                       'default' => :default}
        HashEngine.action('lookup_map', action_data, :key3).should == :default
      end

      it 'returns the key on a miss' do
        action_data = {:key1 => :value1,
                       :key2 => :value2,
                       'default_to_key' => true}
        HashEngine.action('lookup_map', action_data, :key3).should == :key3
      end
    end

    describe 'of type: first_value' do
      it 'returns data if data is not an array' do
        HashEngine.action('first_value', nil, '0123456789').should == '0123456789'
      end

      it 'returns the first non-nil value' do
        HashEngine.action('first_value', nil, [nil, '0123456789']).should == '0123456789'
      end
    end

    describe 'of type: join' do
      it 'returns data elements joined' do
        HashEngine.action('join', nil, ['foo', 'bar']).should == 'foobar'
      end

      it 'returns data elements as strings joined' do
        HashEngine.action('join', nil, [:foo, :bar]).should == 'foobar'
      end

      it 'returns data elements joined by specified seperator' do
        HashEngine.action('join', ', ', ['foo', 'bar']).should == 'foo, bar'
      end

      it 'returns data elements with an included nil joined by specified seperator' do
        HashEngine.action('join', ', ', [nil, 'bar']).should == ', bar'
      end

      it 'returns data if data is not an array' do
        HashEngine.action('join', ', ', 'foo').should == 'foo'
      end
    end

    describe 'of type: max_length' do
      it 'returns an unaltered string when less than length' do
        HashEngine.action('max_length', 50, '0123456789').should == '0123456789'
      end

      it 'returns a number as a string when less than length' do
        HashEngine.action('max_length', 50, 123456789).should == '123456789'
      end

      it 'trims the string when longer than length' do
        HashEngine.action('max_length', 5, '0123456789').should == '01234'
      end

      it 'trims a number when longer than length' do
        HashEngine.action('max_length', 5, 123456789).should == '12345'
      end

      it 'trims unicode string when longer than length' do
        HashEngine.action('max_length', 3, 'ÑAlaman').should == 'ÑAl'
      end
    end
  end
end
