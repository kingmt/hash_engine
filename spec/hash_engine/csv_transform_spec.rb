require 'hash_engine'

describe HashEngine do
  describe 'csv transform' do
  # Given String:
  #     ok|http://www.domain.com|1234567890
  # Given Instructions:
  #     delimiter: '|'
  #     hash_keys:
  #       - status:
  #           lookup_map:
  #             ok: accepted
  #             decline: reject
  #             default: error
  #       - payload:
  #       - uuid:
  # Return:
  #     status: accepted
  #     payload: http://www.domain.com
  #     uuid: 1234567890

    it 'nil case' do
      string = 'ok||1234567890'
      instructions = {'delimiter' => '|',
                      'allow_nil' => true,
                      'suppress_nil' => false,
                      'header' => ['status',
                                   'payload',
                                   'uuid'],
                      'fields' => {'status' => {'input' => 'status'},
                                   'payload' => {'input' => 'payload'},
                                   'uuid' => {'input' => 'uuid'}} }
      expected = {:error => [],
                  'status' => 'ok',
                  'payload' => nil,
                  'uuid' => '1234567890'}
      HashEngine.csv_transform(string, instructions).should == expected
    end

    it 'trivial case' do
      string = 'ok|http://www.domain.com|1234567890'
      instructions = {'delimiter' => '|',
                      'header' => ['status',
                                   'payload',
                                   'uuid'],
                      'fields' => {'status' => 'status',
                                   'payload' => 'payload',
                                   'uuid' => 'uuid'} }
      expected = {:error => [],
                  'status' => 'ok',
                  'payload' => 'http://www.domain.com',
                  'uuid' => '1234567890'}
      HashEngine.csv_transform(string, instructions).should == expected
    end

    it 'simple formatting' do
      string = 'ok|http://www.domain.com|ABCD1234'
      instructions = {'delimiter' => '|',
                      'header' => ['status',
                                   'payload',
                                   'uuid'],
                      'fields' => {'status' => {'input' => 'status'},
                                   'payload' => {'input' => 'payload'},
                                   'uuid' => {'input' => 'uuid', 'format' => 'numeric'}}}
      expected = {:error => [],
                  'status' => 'ok',
                  'payload' => 'http://www.domain.com',
                  'uuid' => '1234'}
      HashEngine.csv_transform(string, instructions).should == expected
    end
    it 'processiong case' do
      string = 'ok|http://www.domain.com|1234567890'
      instructions = {'delimiter' => '|',
                      'header' => ['status',
                                   'payload',
                                   'uuid'],
                      'fields' => {'status' => {'input' => 'status',
                                                'lookup_map' =>{'ok' => 'accepted',
                                                                    'decline' => 'reject',
                                                                    'default' => 'error'}},
                                   'payload' => {'input' => 'payload'},
                                   'uuid' => {'input' => 'uuid'}} }
      expected = {:error => [],
                  'status' => 'accepted',
                  'payload' => 'http://www.domain.com',
                  'uuid' => '1234567890'}
      HashEngine.csv_transform(string, instructions).should == expected
    end
  end
end
