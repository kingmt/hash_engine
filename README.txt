= hash_engine

HashEngine is designed to operate on inputs given a hash of instructions to genetate an output hash
HashEngine is compatible with Ruby versions 1.8.7, 1.9, and 2.0, mostly because I have a legacy project still on 1.8.7.

The primary manipulations HashEngin is capable of are:
* Transform => given a hash and instructions generate an output hash
* CsvTransform => given a string, instructions, and additional data generate an output hash
* Extract => given a hash of Objects and instructions generate an output hash

HashEngine has several functions built in which will be covered below, however HashEngine was designed with extensability and customizability in mind. You can add your own functions and/or remove some of the built in functions.

There are two main classes of instructions for HashEngine, fetchers and actions.
  Fetchers are instructions to 'fetch' data.
  Actions are instructions which 'act' on previously fetched data.
  A majority of tranformations involve only one fetcher and action, but can specify multiple instructions.

  1.8.7 vs 1.9 and 2.0
    Since hashes in 1.8.7 do not remembering insert order all instruction chaining needs to be specified as array elements.
    The exception being a single fetcher followed by a single action, which can be specified as an array.

== Fetchers
The defined fetchers are:
* literal
* input
* data
* subgroup_input
* conditional_input

The data that has been fetched will be accumulated and passed into the following action
For all examples below assume the data passed in is:
--
  data_key_1: data_value_1
  data_key_2: data_value_2
  data_key_3: data_value_3
  data_key_4: data_value_4
  data_key_5: data_value_5

* * literal -- used to specify literal or constant values
    YAML examples:
    output_1:
      literal: foo
    output_2:
      literal: ''
* * input -- used to specify the key of the data hash to be used
    YAML example:
    output_1:
      input: data_key_1
* * data -- used to specify multiple keys of the data hash to be used
    YAML example:
    output_1:
      data:
        - data_key_1
        - data_key_2
      join: ', '
      Result would be => data_value_1, data_value_2
* * subgroup_input -- used when some data needs to be acted upon before being used as an input, all defined fetchers and actions can be used. Technically you could define a highly nested structure, but it is not recomended.
    YAML example:
    output_1:
      - subgroup:
          data:
            - data_key_1
            - data_key_2
          join: ', '
      - input: data_key_3
      - join: '#'
      Result would be => data_value_1, data_value_2#data_value_3
* * conditional_input -- variant of subgroup_input where conditional logic is applied to the data, the equivalent Ruby code would be:
                         if left_operand operator right_operand
                           true_instructions
                         else
                           false_instructions

    -- The structure of this fetcher is a bit different
       There must be a fetcher specified for the
    * * left_operand and right_operand can be any valid fetcher
    * * operators
        eq => equal
        ne => not equal
        lt => less than
        gt => greater than
        lteq => less than or equal to
        gteq => greater than or equal to
        exist => exists
    * * true_instructions and false_instructions can be any valid combination of fetchers and actions
    YAML example:
    output_1:
      - conditional_input:
          left_operand:
            input: data_key_1
          operator: exist
          true:
            input: data_key_2
          false:
            input: data_key_3
      - input: data_key_3
      - join: '#'
      When data_value_1 exists the result would be => data_value_2#data_value_3
      When data_value_1 doesn't exist the result would be => data_value_3#data_value_3
    output_2:
      conditional_input:
        left_operand
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
      When data_value_1 is the same as data_value_4 the result would be => data_value_2#data_value_3
      When data_value_1 is not the same as data_value_4 the result would be => data_value_1#data_value_4




== Actions
The main actions are:
* lookup_map
* first_value
* join
* max_length
* format

== Global settings
* default_value
* allow_nil
* suppress_nil
* allow_blank
* suppress_blank
* quiet
* optional

The version of Ruby in use will change how multiple instructions must be specified to maintain the correct order of operations. In Ruby 1.8 an Array must be used, however since Ruby 1.9 Hashes maintain insertion order an Array or Hash can be used.

Input Data Type:
* hash
  Inputs:
  * input
  * literal
  * data
* xml
  Inputs:
  * css
  * xpath
* string
* object
  Inputs: method names


== Builtin Actions:
* lookup_map => mostly equivalent to a hash lookup, the differences are because Hashes loaded from YAML don't have default procs
  modifiers:  default: <default value> => will return <default_value> if input is not found
              default_to_key: true => will return the key if input is not found
  for example given the following instructions:
   output_field_1:
     - input: foo
     - lookup_map:
         x: 1
         y: 2
   output_field_2:
     - input: bar
     - lookup_map:
         x: 1
         y: 2
         default: 0
   output_field_3:
     - input: baz
     - lookup_map:
         x: 1
         y: 2
         default_to_key: true
  and the source data => {'foo' => 'z', 'bar' => 'z', 'baz' => 'z'}
    the output will be {'output_field_1 => nil

* first_value => find the first non-nil value
    YAML example:
    output_1:
      data:
        - data_key_1
        - data_key_2
      join: ', '
      When data_value_1 exists the result would be => data_value_1
      When data_value_1 doesn't exist the result would be => data_value_2
* join => join all the data using the specified string
    YAML example:
    output_1:
      data:
        - data_key_1
        - data_key_2
      join: ', '
      Result would be => data_value_1, data_value_2
* max_length => cut the output down to the size specified
    YAML example:
    output_1:
      input: data_key_1
      max_length: 8
      Result would be => data_val

* strtfmt: <pattern>
  This will call strfmt using the supplied pattern on the value if the value responds to strfmt
* format: <sub-action>
  These are for formatting or casting values
  The built in formats are:
  * string = effectively calls to_s on the value, as well as stripping all leading and trailing spaces, examples (initial, result):
  * * 'sample' => 'sample'
  * * '  sample' => 'sample'
  * * 'sample  ' => 'sample'
  * * '  sample  ' => 'sample'
  * * 55 => '55'
  * * :sample => 'sample'

  * first = returns first character, if needed calls to_s first, examples (initial, result):
  * * 'sample' => 's'
  * * 55 => '5'

  * alphanumeric = , examples (initial, result):
  * * 'sample' => 'sample'
  * * 's_a+m=p%l-e' => 'sample'
  * * 55 => '55'

  * no_whitespace = , examples (initial, result):
  * * 'sample' => 'sample'
  * * 'sam-ple' => 'sam-ple'
  * * 's_a+m=p%le' => 'sample'
  * * 55 => '55'

  * alpha = calls to_s on value and then keeps only a-zA-Z, examples (initial, result):
  * * '123sample' => 'sample'
  * * 's_a45m=p%l-e' => 'sample'

  * numeric = keeps only digits 0-9, examples (initial, result):
  * * '123sample' => '123'
  * * '682-59-7267' => '682597267'
  * * 'ext 99' => '99'

  * float = calls to_f, examples (initial, result):
  * * '2000.99' => 2000.99

  * integer = calls to_i with the following exceptions, true => 1, nil and false => 0, examples (initial, result):
  * * 'sample' => 0
  * * '123sample' => 123
  * * 55 => 55
  * * true => 1
  * * false => 0
  * * nil => 0

  * boolean = converts values to true or false, examples (initial, result):
  * * 'true' => true
  * * true => true
  * * 'TrUe' => true
  * * 't' => true
  * * 'T' => true
  * * 1 => true
  * * 'yes' => true
  * * 'Y' => true
  * * 2 => false
  * * 'false' => false
  * * false => false
  * * 'no' => false

  * upcase = changes all characters to upper case, examples (initial, result):
  * * 'sample' => 'SAMPLE'
  * * true => 'TRUE'

  * capitalize = capitalizes the string, examples (initial, result):
  * * 'sample' => 'Sample'

  * downcase = changes all characters to lower case, examples (initial, result):
  * * 'TRUE' => 'true'


== Adding/Removing/Changing Actions
To add a new action using a block do:
  HashEngine.register_action_block('first_value') {|data, action_data, error_array|
        data.find {|field| (field && !field.empty?) }
    }

To change a action, simply register the new action.
To delete a action use:
  HashEngine.remove_format_block('float')

== Adding/Removing/Changing Formats
To add a new format using a block do:
  HashEngine.register_format_block('float') {|data| data.to_f}

To add a new format using a hash do:
  i_hash = Hash.new {|hash, key| key.to_i }
  i_hash[true]  = 1
  i_hash[false] = 0
  i_hash[nil]   = 0
  HashEngine.register_format_hash('integer', i_hash)

To change a format, simply register the new format.
To delete a format use:
  HashEngine.remove_format_block('float')


== Contributing to hash_engine

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

== Copyright

Copyright (c) 2011-2012 Michael King (kingmt@gmail.com).
