require 'hash_engine'

describe HashEngine do
  describe 'valid_fetcher?' do
    it 'returns true when key exists' do
      HashEngine.valid_fetcher?('input').should be_true
    end

    it 'returns false when key does not exist' do
      HashEngine.valid_fetcher?('foo').should be_false
    end
  end

  describe 'fetcher' do
    it 'returns the input field from customer_data' do
      HashEngine.fetcher('input', 'foo', {'foo' => 'bar'}).should == 'bar'
    end

    it 'returns the literal' do
      HashEngine.fetcher('literal', 'foo', {'foo' => 'bar'}).should == 'foo'
    end

    it 'returns multiple data fields' do
      customer_data = {:field1 => :value1, :field2 => :value2}
      field_data = [:field1, :field2]
      expected = [:value1, :value2]
      HashEngine.fetcher('data', field_data, customer_data).should == expected
    end
  end
end
