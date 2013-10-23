require 'hash_engine'
require 'yaml'

describe HashEngine do
  describe 'nil_check' do
    it { HashEngine.nil_check({'allow_nil' => false}, nil).should be_true }
    it { HashEngine.nil_check({'allow_nil' => true}, nil).should be_false }
    it { HashEngine.nil_check({'allow_nil' => false}, :ll).should be_false }
  end

  describe 'blank_check' do
    it { HashEngine.blank_check({'allow_blank' => false}, '').should be_true }
    it { HashEngine.blank_check({'allow_blank' => false}, '  ').should be_true }
    it { HashEngine.blank_check({'allow_blank' => true}, '').should be_false }
    it { HashEngine.blank_check({'allow_blank' => false}, 'string').should be_false }
  end

  describe 'required_check' do
    it { HashEngine.required_check({'optional' => true}).should be_false }
    it { HashEngine.required_check({}).should be_true }
    it { HashEngine.required_check({'optional' => false}).should be_true }
  end

  describe 'suppress_nil' do
    it { HashEngine.suppress_nil({'suppress_nil' => true}, nil).should be_true }
    it { HashEngine.suppress_nil({'suppress_nil' => false}, nil).should be_false }
    it { HashEngine.suppress_nil({'suppress_nil' => true}, :ll).should be_false }
  end

  describe 'suppress_blank' do
    it { HashEngine.suppress_blank({'suppress_blank' => true}, '').should be_true }
    it { HashEngine.suppress_blank({'suppress_blank' => true}, '  ').should be_true }
    it { HashEngine.suppress_blank({'suppress_blank' => false}, '').should be_false }
    it { HashEngine.suppress_blank({'suppress_blank' => true}, 'string').should be_false }
  end

  it 'default_or_supress'

  it 'transform'

  it 'simple_instructions'

  describe 'concat' do
    it 'returns arg2 if arg1 is nil' do
      HashEngine.concat(nil, :arg).should == :arg
    end

    it 'combines arg1 + arg2 when both are arrays' do
      arg1 = [:arg1_1, :arg1_2]
      arg2 = [:arg2_1, :arg2_2]
      HashEngine.concat(arg1, arg2).should == [:arg1_1, :arg1_2, :arg2_1, :arg2_2]
    end

    it 'adds arg2 to the end when arg1 is an array' do
      arg1 = [:arg1_1, :arg1_2]
      HashEngine.concat(arg1, :arg2).should == [:arg1_1, :arg1_2, :arg2]
    end

    it 'puts arg1 at the front when arg2 is an array' do
      arg2 = [:arg2_1, :arg2_2]
      HashEngine.concat(:arg1, arg2).should == [:arg1, :arg2_1, :arg2_2]
    end

    it 'creates an array when niether arg1 or arg2 is' do
      HashEngine.concat(:arg1, :arg2).should == [:arg1, :arg2]
    end
  end

  it 'process_instructions'

  it 'get_value'

# output_2:
#   conditional_input:
#     left_operand
#       input: data_key_1
#     operator: eq
#     right_operand:
#       input: data_key_4
#     true_instructions:
#       data:
#         - data_key_2
#         - data_key_3
#       join: '#'
#     false_instructions:
#       data:
#         - data_key_1
#         - data_key_4
#       join: '#'
#   When data_value_1 is the same as data_value_4 the result would be => data_value_2#data_value_3
#   When data_value_1 is not the same as data_value_4 the result would be => data_value_1#data_value_4
  describe 'conditional_eval' do
    let(:data) do
      {'data_key_1' => 'data_value_1',
       'data_key_2' => 'data_value_2',
       'data_key_3' => 'data_value_3',
       'data_key_4' => 'data_value_4',
       'data_key_5' => 'data_value_5'}
    end

    context 'specified in an array' do
      it 'handles trivial case' do
        yaml =<<EOYAML
fields:
  status:
    - conditional_eval:
        left_operand:
          input: data_key_1
        operator: eq
        right_operand:
          input: data_key_4
        true_instructions:
          input: data_key_2
        false_instructions:
          input: data_key_3
EOYAML
        instructions = YAML.load yaml
        results = HashEngine.transform(data, instructions)
        results[:error].should == []
        results['status'].should == 'data_value_3'
      end

      it 'handles complex operand' do
        yaml =<<EOYAML
fields:
  status:
    - conditional_eval:
        left_operand:
          data:
            - data_key_2
            - data_key_3
          join: '#'
        operator: eq
        right_operand:
          input: data_key_4
        true_instructions:
          input: data_key_2
        false_instructions:
          input: data_key_3
EOYAML
        instructions = YAML.load yaml
        results = HashEngine.transform(data, instructions)
        results[:error].should == []
        results['status'].should == 'data_value_3'
      end

      it 'handles complex result instructions' do
        yaml =<<EOYAML
fields:
  status:
    - conditional_eval:
        left_operand:
          input: data_key_1
        operator: eq
        right_operand:
          input: data_key_4
        true_instructions:
          data:
            - data_key_2
            - data_key_3
          join: '#'
        false_instructions:
          data:
            - data_key_1
            - data_key_4
          join: '#'
EOYAML
        instructions = YAML.load yaml
        results = HashEngine.transform(data, instructions)
        results[:error].should == []
        results['status'].should == 'data_value_1#data_value_4'
      end
    end

    context 'specified in a hash' do
      it 'handles trivial case' do
        yaml =<<EOYAML
fields:
  status:
    conditional_eval:
      left_operand:
        input: data_key_1
      operator: eq
      right_operand:
        input: data_key_4
      true_instructions:
        input: data_key_2
      false_instructions:
        input: data_key_3
EOYAML
        instructions = YAML.load yaml
        results = HashEngine.transform(data, instructions)
        results[:error].should == []
        results['status'].should == 'data_value_3'
      end

      it 'handles complex operand' do
        yaml =<<EOYAML
fields:
  status:
    conditional_eval:
      left_operand:
        data:
          - data_key_2
          - data_key_3
        join: '#'
      operator: eq
      right_operand:
        input: data_key_4
      true_instructions:
        input: data_key_2
      false_instructions:
        input: data_key_3
EOYAML
        instructions = YAML.load yaml
        results = HashEngine.transform(data, instructions)
        results[:error].should == []
        results['status'].should == 'data_value_3'
      end

      it 'handles complex result instructions' do
        yaml =<<EOYAML
fields:
  status:
    conditional_eval:
      left_operand:
        input: data_key_1
      operator: eq
      right_operand:
        input: data_key_4
      true_instructions:
        data:
          - data_key_2
          - data_key_3
        join: '#'
      false_instructions:
        data:
          - data_key_1
          - data_key_4
        join: '#'
EOYAML
        instructions = YAML.load yaml
        results = HashEngine.transform(data, instructions)
        results[:error].should == []
        results['status'].should == 'data_value_1#data_value_4'
      end
    end
  end

  describe 'transformation' do
    let(:data) do
      {'vendor_status' => 'ok',
       'vendor_payload' => 'http://www.domain.com',
       'vendor_uuid' => '1234ABCD'}
    end

    it 'trivial case' do
      yaml =<<EOYAML
fields:
  payload: vendor_payload
EOYAML
      instructions = YAML.load yaml
      results = HashEngine.transform(data, instructions)
      results[:error].should be_empty
      results['payload'].should == 'http://www.domain.com'
    end

    it 'simple case' do
      yaml =<<EOYAML
fields:
  payload:
    input: vendor_payload
EOYAML
      instructions = YAML.load yaml
      results = HashEngine.transform(data, instructions)
      results[:error].should be_empty
      results['payload'].should == 'http://www.domain.com'
    end

    it 'simple formatting' do
      yaml =<<EOYAML
fields:
  uuid:
    input: vendor_uuid
    format: numeric
EOYAML
      instructions = YAML.load yaml
      results = HashEngine.transform(data, instructions)
      results[:error].should be_empty
      results['uuid'].should == '1234'
    end

    it 'lookup map case' do
      yaml =<<EOYAML
fields:
  status:
    input: vendor_status
    lookup_map:
      ok: accepted
      decline: reject
      default: error
EOYAML
      instructions = YAML.load yaml
      results = HashEngine.transform(data, instructions)
      results[:error].should be_empty
      results['status'].should == 'accepted'
    end

    it 'copied source case' do
      yaml =<<EOYAML
copy_source: true
fields:
  status:
    input: vendor_status
    lookup_map:
      ok: accepted
      decline: reject
      default: error
EOYAML
      instructions = YAML.load yaml
      results = HashEngine.transform(data, instructions)
      expected = {'vendor_status' => 'ok',
                   'vendor_payload' => 'http://www.domain.com',
                   'vendor_uuid' => '1234ABCD',
                   :error => [],
                   'status' => 'accepted'}
      results.should == expected
    end

    it 'multiple data case' do
      yaml =<<EOYAML
fields:
  status:
    - input: vendor_status
    - data:
       - vendor_status
       - vendor_status
    - join: ', '
EOYAML
      instructions = YAML.load yaml
      results = HashEngine.transform(data, instructions)
      results[:error].should be_empty
      results['status'].should == 'ok, ok, ok'
    end

    it 'multiple data case with an action in the middle' do
      yaml =<<EOYAML
fields:
  status:
    - input: vendor_status
    - subgroup:
        input: vendor_status
        lookup_map:
          ok: accepted
          decline: reject
          default: error
    - join: ', '
EOYAML
      instructions = YAML.load yaml
      results = HashEngine.transform(data, instructions)
      results[:error].should be_empty
      results['status'].should == 'ok, accepted'
    end
  end
end
