require 'hash_engine'
require 'yaml'

describe HashEngine do
  let(:data) { {'first'=>'Firstname', 'last'=>'Lastname', 'set_number' => 12} }
  let(:alt_data) { {'first'=>'Firstname', 'set_number' => 12} }

  it 'joins first+seperator+last' do
    instructions = {'fields'=>
                     {'name_field'=>
                       [{'data' => ['first',
                                    'last']},
                        {'join'=> '\#' }]}}
    results = HashEngine.transform(data, instructions)
    results['name_field'].should == 'Firstname\#Lastname'
  end

  it 'joins first+seperator+first+seperator+first+seperator+last' do
    instructions = {'fields'=>
                     {'name_field'=>
                       [{'data' => ['first',
                                    'first',
                                    'first',
                                    'last']},
                        {'join'=> '\#' }]}}
    results = HashEngine.transform(data, instructions)
    results['name_field'].should == 'Firstname\#Firstname\#Firstname\#Lastname'
  end

  it 'joins last+seperator+first' do
    instructions = {'fields'=>
                     {'name_field'=>
                       [{'data' => ['last',
                                    'first']},
                        {'join'=> '\#' }]}}
    results = HashEngine.transform(data, instructions)
    results['name_field'].should == 'Lastname\#Firstname'
  end

  it 'joins last+seperator+last+seperator+first' do
    instructions = {'fields'=>
                     {'name_field'=>
                       [{'data' => ['last',
                                    'last',
                                    'first']},
                        {'join'=> '\#' }]}}
    results = HashEngine.transform(data, instructions)
    results['name_field'].should == 'Lastname\#Lastname\#Firstname'
  end

  it '"#{first_name}#{separator}#{last_name}<Wrapper=#{wrapper_set}>"' do
      yaml =<<EOYAML
fields:
  name_field:
    - subgroup:
        data:
          - first
          - last
        join: '\\#'
    - literal: '<Wrapper='
    - input: set_number
    - literal: '>'
    - join:
EOYAML
      instructions = YAML.load yaml
    results = HashEngine.transform(data, instructions)
    results['name_field'].should == 'Firstname\#Lastname<Wrapper=12>'
  end

  it '"#{first_name}#{separator}#{last_name}#{separator}#{first_name}#{separator}#{last_name}#{separator}#{first_name}#{separator}#{last_name}#{separator}#{first_name}#{separator}#{last_name}#{separator}#{first_name}#{separator}#{last_name}"' do
    instructions = {'fields'=>
                     {'name_field'=>
                       [{'data' => [ 'first','last','first','last','first','last','first','last','first','last' ]},
                        {'join'=> '\#' }]}}
    results = HashEngine.transform(data, instructions)
    results['name_field'].should == 'Firstname\#Lastname\#Firstname\#Lastname\#Firstname\#Lastname\#Firstname\#Lastname\#Firstname\#Lastname'
  end

  context 'last_name.present? ? "#{first_name}#{separator}#{last_name}" : "#{first_name}#{separator}#{first_name}"' do
    let(:instructions) do
      {'fields'=>
        {'name_field'=>
          [{'input' => 'first'},
           {'data' => ['last',
                       'first']},
           {'first_value'=>nil},
           {'join'=> '\#' }]}}
      yaml =<<EOYAML
fields:
  name_field:
    - input: first
    - subgroup:
        data:
          - last
          - first
        first_value:
    - join: '\\#'
EOYAML
      instructions = YAML.load yaml
    end

    it 'last name present' do
      results = HashEngine.transform(data, instructions)
      results['name_field'].should == 'Firstname\#Lastname'
    end

    it 'last name blank' do
      results = HashEngine.transform(alt_data, instructions)
      results['name_field'].should == 'Firstname\#Firstname'
    end
  end

  context 'last_name.present? ? "#{last_name}" : "#{first_name}"' do
    let(:instructions) do
      {'fields'=>
        {'name_field'=>
          [{'data' => ['last',
                       'first']},
           {'first_value'=>nil}]}}
    end

    it 'last name present' do
      results = HashEngine.transform(data, instructions)
      results['name_field'].should == 'Lastname'
    end

    it 'last name blank' do
      results = HashEngine.transform(alt_data, instructions)
      results['name_field'].should == 'Firstname'
    end
  end

  context 'last_name.present? ? "#{first_name}#{separator}#{last_name}" : "#{separator}#{first_name}"' do
    let(:instructions) do
      yaml =<<EOYAML
fields:
  name_field:
    - conditional_input:
        input: last
        test: ne
        test_value:
        true:
          input: first
        false:
          literal: ''
    - subgroup_input:
        data:
          - last
          - first
        first_value:
    - join: '\\#'
EOYAML
      YAML.load yaml
    end

    it 'last name present' do
      pending
      results = HashEngine.transform(data, instructions)
      results['name_field'].should == 'Firstname\#Lastname'
    end

    it 'last name blank' do
      pending
      results = HashEngine.transform(alt_data, instructions)
      results['name_field'].should == '\#Firstname'
    end
  end

  it '"#{first_name} #{last_name}"' do
    instructions = {'fields'=>
                     {'name_field'=>
                       [{'data' => ['first',
                                    'last']},
                        {'join'=> ' ' }]}}
    results = HashEngine.transform(data, instructions)
    results['name_field'].should == 'Firstname Lastname'
  end
end
