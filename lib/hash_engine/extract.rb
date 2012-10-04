require 'hash_engine/format'

module HashEngine
  module Extract
    include Format

    @@reserved_keys ||= {'method' => true, 'method_args' => true, 'cast' => true, 'required' => true}.freeze

    # Collects data from a root object based on the provided instructions hash.
    # The data is returned as a flat hash. A hash is used to specify the set of
    # attributes which should be included in the .

    def extract(objects, instructions)
      if instructions.nil? || instructions.empty?
        # can't do anything
        {:error => ['Missing instructions']}
      else
        objects_to_walk = instructions.keys
        if objects.nil?
          {:error => ['Missing object(s)']}
        else
          if objects.is_a?(Hash)
            # hash path
            objects_given = objects.keys
            if delta = objects_to_walk - objects_given and
               !delta.empty?
              {:error => ["Missing object(s): #{(delta).sort.join(', ')}"]}
            else
              # instructions for objects a, b, c
              # given objects a, b, c
              fetch_objects(objects_hash, objects_to_walk, instructions)
            end
          else
            # single object path
            if objects_to_walk.size > 1
              {:error => ["Instructions given for #{objects_to_walk.sort.join(', ')} but only 1 object given"]}
            else
              # instructions for 1 object
              # given 1 object
              object_name = objects_to_walk.first
              fetch_objects({object_name => objects}, objects_to_walk, instructions)
            end
          end
        end
      end
    end

    def fetch_objects(objects_hash, objects_to_walk, instructions)
      results = {:error => []}
      objects_to_walk.each do |object_name|
        instructions[object_name].each_pair do |field, field_instructions|
          # Command keywords are reserved and will not be walked.
          unless @@reserved_keys.has_key?(field)
            fetch_value(field, field_instructions, objects_hash[object_name], object_name, instructions[object_name], results)
          end
        end
      end
      results
    end

    def fetch_attributes(object, parent_name, object_hash, results)
      object_hash.each_pair do |field, field_instructions|
        # Command keywords are reserved and will not be walked.
        unless @@reserved_keys.has_key?(field)
          fetch_value(field, field_instructions, object, parent_name, object_hash, results)
        end
      end
    end

    def fetch_value(field, field_instructions, object, parent_name, object_hash, results)
      # puts "      Field: #{field} field_instructions #{field_instructions.inspect} object #{object.inspect}"
      method = fetch_method(object, field, field_instructions)
      # puts "        Method: #{method.inspect}"
      args = fetch_method_args(field, field_instructions)
      if method
        return_val = object.send(method, *args)
        return_val = cast_value(return_val, field, field_instructions)
        # check if we need to dive deeper into recursion
        set_result_or_recurse(return_val, parent_name, field, field_instructions, results)
      else
        append_error_for_required_fields(results,
          "#{parent_name} does not respond to any of: #{fetch_method_array(field, field_instructions).join(', ')}", field_instructions)
      end
    end

    def set_result_or_recurse(return_val, parent_name, field, field_instructions, results)
      if field_instructions && field_instructions.keys.any? {|k| !@@reserved_keys.has_key?(k) }
        # yes, dive!
        if return_val.nil?
          append_error_for_required_fields(results, "Missing required field: #{parent_name}.#{field}", field_instructions)
        else
          fetch_attributes(return_val, "#{parent_name}.#{field}", field_instructions, results)
        end
      else
        # no, add to results
        results[field] = return_val
      end
    end

    def cast_value(return_val, field, field_instructions)
      if field_instructions && field_instructions.has_key?('cast')
        return_val = format_value(return_val, field_instructions['cast'])
      else
        return_val
      end
    end

    def fetch_method_array(field, field_instructions)
      # Don't use compact! => returns nil if unchanged instead of returning the unchanged array
      [(field_instructions && field_instructions['method']), field, field+'?'].compact
    end

    # Identify the method to be called.
    def fetch_method(object, field, field_instructions)
      fetch_method_array(field, field_instructions).detect {|method|
        object.respond_to?(method) }
    end

    def fetch_method_args(field, field_instructions)
      if field_instructions && field_instructions['method_args']
        # if args specified make sure its an array
        if field_instructions['method_args'].is_a?(Array)
          field_instructions['method_args']
        else
          [ field_instructions['method_args'] ]
        end
      else
        []
      end
    end

    def append_error_for_required_fields(results, message, instructions)
      # Only log an error for required fields.
      if (!instructions || instructions.fetch('required', true))
        results[:error] << message
      end
    end
  end
end
