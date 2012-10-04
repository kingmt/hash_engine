require 'hash_engine/format'

module HashEngine
  module Actions

    include Format

    @@actions = {}

    def actions
      @@actions
    end

    def add_action name, &block
      @@actions[name] = block
    end

    def valid_action?(action)
      actions.has_key?(action)
    end

    def action(type, field_data, fetched_data)
      if valid_action?(type)
        actions[type].call(fetched_data, field_data)
      end
    end

    unprotected_proc = Proc.new do |data, action_data|
      if action_data.is_a?(Proc)
        action_data.call(*data)
      else
        eval(action_data).call(*data)
      end
    end

    @@actions['proc'] = Proc.new do |data, action_data|
      if data.is_a?(Array) && data.any?(&:nil?) || data.nil?
        nil
      else
        unprotected_proc.call(data, action_data)
      end
    end

    @@actions['unprotected_proc'] = unprotected_proc

    @@actions['lookup_map'] = Proc.new do |key, hash|
      if hash.has_key?(key) ||
         hash.default ||
         hash.default_proc then
        hash[key]
      elsif hash.has_key?('default') then
        hash['default']
      elsif hash.has_key?('default_to_key')
        key
      end
    end

    @@actions['join'] = Proc.new {|data, sep| data.is_a?(Array) ? data.join(sep) : data }
    @@actions['first_value'] = Proc.new { |data, first| data.is_a?(Array) ? data.detect {|f| !(f.nil? || f.empty?)} : data }
    @@actions['max_length'] = Proc.new {|data, length| data.to_s.slice(0, length.to_i) }
    @@actions['format'] = Proc.new do |data, format_instructions|
      # puts "      Formatting data: #{data} with #{format_instructions}"
      if format_instructions.is_a?(Hash) &&
         format_instructions.has_key?('strftime') &&
         data.respond_to?(:strftime) then
        data.send(:strftime, format_instructions['strftime'])
      elsif @@formats.has_key?(format_instructions)
        @@formats[format_instructions][data]
      else
        data
      end
    end

  end
end
