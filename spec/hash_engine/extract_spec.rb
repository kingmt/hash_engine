require 'hash_engine'

describe HashEngine do
  describe 'extract' do
    describe 'should return errors' do
      it 'when instructions is empty' do
        HashEngine.extract(nil, {}).should ==
          {:error => ['Missing instructions']}
      end

      it 'when instructions are nil' do
        HashEngine.extract(nil, nil).should ==
          {:error => ['Missing instructions']}
      end

      it 'when object is mil' do
        HashEngine.extract(nil, {'person' => 'person'}).should ==
          {:error => ['Missing object(s)']}
      end

      it 'when number of objects dont match instructions' do
        objects = mock 'Person'
        instructions = {'person' => 'person', 'company' => 'company'}
        HashEngine.extract(objects, instructions).should ==
          {:error => ['Instructions given for company, person but only 1 object given']}
      end

      it 'when instructions wants a missing object' do
        objects = {'person' => 'person', 'address' => 'address'}
        instructions = {'person' => 'person', 'company' => 'company'}
        HashEngine.extract(objects, instructions).should ==
          {:error => ['Missing object(s): company']}
      end
    end

    describe 'return values' do
      before :each do
        @instructions = {'person' => {'first_name' => nil,
                                      'name' => nil,
                                      'military' => nil,
                                      'dob' => {'method' => 'date_of_birth'}
                                     }
                        }
        @person = mock 'Person', :first_name => 'Mark',
                                # :name => 'Mark',
                                 :military? => false,
                                 :date_of_birth => Time.at(0)
        @output = HashEngine.extract(@person,@instructions)
      end

      it 'should get "Mark" for first_name' do
        @output['first_name'].should == 'Mark'
      end

      it 'should get "false" for military' do
        @output['military'].should == false
      end

      it 'should get "" for dob' do
        @output['dob'].should == Time.at(0)
      end

      it 'should not have name' do
        @output['name'].should == nil
        @output.has_key?('name').should == false
      end

      it 'should have error for missing name' do
        @output[:error].should == ["person does not respond to any of: name, name?"]
      end
    end
  end

 
  it 'fetch_objects'

  describe 'fetch_attributes' do
    it 'should check each field'
    it 'should not fetch_value for reserved keys'
  end

  describe 'fetch_value' do
    it 'should call a method on the object'
    it 'should add an error if the object doesnt respond to the method'
  end

  describe 'set_result_or_recurse' do
    it 'should set result'
    it 'should append error'
    it 'should recurse'
  end

  describe 'fetch_method_array' do
    it 'should return 3 elements' do
      HashEngine.fetch_method_array('field', {'method' => 'other_field'}).should == ['other_field', 'field', 'field?']
    end

    it 'should return 2 elements' do
      HashEngine.fetch_method_array('field', nil).should == ['field', 'field?']
    end
  end

  describe 'fetch_method' do
    it 'should return method' do
      object = mock 'Object', :other_field => :foo
      HashEngine.fetch_method(object, 'field', {'method' => 'other_field'}).should == 'other_field'
    end

    it 'should return field' do
      object = mock 'Object', :field => :foo
      HashEngine.fetch_method(object, 'field', nil).should == 'field'
    end

    it 'should return field?' do
      object = mock 'Object', :field? => :foo
      HashEngine.fetch_method(object, 'field', nil).should == 'field?'
    end

    it 'should return nil' do
      object = mock 'Object', :other_field => :foo
      HashEngine.fetch_method(object, 'field', nil).should == nil
    end
  end

  describe 'fetch_method_args' do
    it 'should return [] when no field_instructions' do
      HashEngine.fetch_method_args(nil, nil).should == []
    end

    it 'should return [] when no args' do
      HashEngine.fetch_method_args(nil, {'method' => 'foo'}).should == []
    end

    it 'should return args unmodified if already an array' do
      HashEngine.fetch_method_args(nil, {'method_args' => ['foo']}).should == ['foo']
    end

    it 'should convert to an array' do
      HashEngine.fetch_method_args(nil, {'method_args' => 'foo'}).should == ['foo']
    end
  end

  it 'append_error_for_required_fields'
end
