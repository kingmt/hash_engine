require 'hash_engine'

describe HashEngine::CSVParse do
  describe 'parse_line' do
    context 'returns correct hash for' do
      it 'simple case' do
        expected = {'field1' => 'foo', 'field2' => 'bar', 'field3' => 'baz', :error => []}
        string = 'foo,bar,baz'
        headers = %w( field1 field2 field3 )
        HashEngine.parse_line(string, headers).should == expected
      end

      it 'field with quote' do
        expected = {'field1' => 'foo', 'field2' => '15"', 'field3' => 'baz', :error => []}
        string = 'foo,15"",baz'
        headers = %w( field1 field2 field3 )
        HashEngine.parse_line(string, headers).should == expected
      end

      it 'quoted field case' do
        expected = {'field1' => 'fubar, real bad', 'field2' => 'bar', 'field3' => 'baz', :error => []}
        string = '"fubar, real bad",bar,baz'
        headers = %w( field1 field2 field3 )
        HashEngine.parse_line(string, headers).should == expected
      end

      it 'nil case' do
        expected = {'field1' => 'foo', 'field2' => nil, 'field3' => 'baz', :error => []}
        string = 'foo,,baz'
        headers = %w( field1 field2 field3 )
        HashEngine.parse_line(string, headers).should == expected
      end

      it 'alternate delimiter case' do
        expected = {'field1' => 'foo', 'field2' => 'bar', 'field3' => 'baz', :error => []}
        string = 'foo|bar|baz'
        headers = %w( field1 field2 field3 )
        HashEngine.parse_line(string, headers, '|').should == expected
      end
    end
  end
end
