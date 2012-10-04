require 'hash_engine/format'
require 'hash_engine/actions'
require 'hash_engine/add_error'
require 'hash_engine/fetchers'
require 'hash_engine/csv_parse'
#require 'csv'

module HashEngine
  module Transform
    include Format
    include Actions
    include AddError
    include Fetchers
    include CSVParse

    DEFAULT_INSTRUCTIONS = {'default_value'  => '',
                            'allow_nil'      => false,
                            'suppress_nil'   => true,
                            'allow_blank'    => false,
                            'suppress_blank' => true,
                            'long_error'     => true,
                            'copy_source'    => false,
                            'delimiter'      => DEFAULT_DELIMITER,
                            'quiet'          => false }

    def nil_check(instructions, value)
      instructions['allow_nil'] == false && value.nil?
    end

    def blank_check(instructions, value)
      instructions['allow_blank'] == false && value.is_a?(String) && value !~ /\S/
    end

    def required_check(field_hash)
      !(field_hash['optional'] == true)
    end

    def suppress_nil(instructions, value)
      instructions['suppress_nil'] == true && value.nil?
    end

    def suppress_blank(instructions, value)
      instructions['suppress_blank'] == true && value.is_a?(String) && value !~ /\S/
    end

    def default_or_suppress(value, field_name, field_hash, instructions, result)
      if (nil_check(instructions, value) || blank_check(instructions, value)) && 
         required_check(field_hash) then
        add_error(result[:error], "required field '#{field_name}' missing", field_name)
        result[field_name] = instructions['default_value']
      else
        unless suppress_nil(instructions, value) || suppress_blank(instructions, value)
          result[field_name] = value
        end
      end
    end

    def transform(data, passed_instructions)
      instructions = DEFAULT_INSTRUCTIONS.merge(passed_instructions)
      if instructions['fields']
        # continue
        result = if instructions['copy_source']
                   data.merge(:error => [])
                 else 
                   {:error => []}
                 end
        result[:error].push(instructions['long_error'] ? :long : :short)
        instructions['fields'].each_pair do |field_name, field_hash|
          value = get_value(field_name, field_hash, data, result[:error])
          default_or_suppress(value, field_name, field_hash, instructions, result)
        end
        # remove the :long/:short instruction
        result[:error].shift
      else
        result = {:error => ["Missing instructions"]}
      end
      result.delete(:error) if instructions['quiet']
      result
    end


  # Given String:
  #     ok|http://www.domain.com|1234567890
  # Given Instructions:
  #     deliminator: '|'
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

    def csv_transform(data_string, passed_instructions, additional_data={})
      instructions = DEFAULT_INSTRUCTIONS.merge(passed_instructions)
      result = {:error => ["Missing CSV instructions"]}
      if instructions['header']
        result = parse_line data_string, instructions['header'], instructions['delimiter']
        result = transform(result.merge(additional_data), instructions) if result[:error].empty?
      end
      result.delete(:error) if instructions['quiet']
      result
    end


    def simple_instructions(field_name, field_hash, source_data, error_array)
      instructions = []
      field_hash.each_pair do |key, value|
        if valid_fetcher?(key)
          instructions.unshift(key => value)
        elsif valid_action?(key)
          instructions.push(key => value)
        else
          add_error(error_array, "Invalid operation '#{key.inspect}' in transform for field '#{field_name}'", field_name)
          data = nil
        end
      end
      process_instructions(field_name, instructions, source_data, error_array)
    end

    def concat(data, fetched)
      if data.nil?
        fetched
      elsif data.is_a?(Array) && fetched.is_a?(Array)
        data + fetched
      elsif data.is_a?(Array) 
        data.push fetched
      elsif fetched.is_a?(Array)
        fetched.unshift(data)
      else
        [data, fetched]
      end
    end

    def process_instructions(field_name, instruction_array, source_data, error_array)
      data = nil
      instruction_array.each do |instruction_hash|
        (instruction, instruction_data) = instruction_hash.first
        # puts "  Evaluating instruction: #{instruction} with instruction_data: #{instruction_data}"
        if valid_fetcher?(instruction)
          fetched = fetcher(instruction, instruction_data, source_data)
          data = concat(data, fetched)
        elsif valid_action?(instruction)
          data = action(instruction, instruction_data, data)
        else
          add_error(error_array, "Invalid operation '#{instruction_hash.inspect}' in transform for field '#{field_name}'", field_name)
          data = nil
          break
        end
      end
      data
    end

    def get_value(field_name, field_data, source_data, error_array)
      case field_data
      when Array
        process_instructions(field_name, field_data, source_data, error_array)
      when Hash
        simple_instructions(field_name, field_data, source_data, error_array)
      else
        fetcher('input', field_data, source_data)
      end
    end
  end
end
