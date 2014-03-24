require 'date'

module HashEngine
  module Format

    @@formats = {}

    def formats
      @@formats
    end

    def add_format name, &block
      @@formats[name] = block
    end

    # leverage the fact that procs and hash have a common interface
    def format(data, format_instructions)
      if format_instructions.is_a?(Hash) &&
         format_instructions.has_key?('strftime') &&
         data.respond_to?(:strftime) then
        data.send(:strftime, format_instructions['strftime'])
      elsif formats.has_key?(format_instructions)
        formats[format_instructions][data]
      else
        data
      end
    end

    # \W includes '_0-9'
    @@formats['alpha'] = Proc.new {|data| data.to_s.gsub(/[^A-Za-z]/,'') }

    # \W includes '_'
    @@formats['alphanumeric'] = Proc.new {|data| data.to_s.gsub(/[^A-Za-z0-9]/,'') }
    @@formats['no_whitespace'] = Proc.new {|data| data.to_s.gsub(/[^A-Za-z0-9-]/,'') }
    @@formats['numeric'] = Proc.new {|data| data.to_s.gsub(/\D/,'') }
    @@formats['string'] = Proc.new {|data| data.to_s.strip }

    # 1.8.7 behavior
    @@formats['first'] = Proc.new {|data| /\w/u.match(data.to_s).to_s }

    # 1.9.x behavior
    if RUBY_VERSION > "1.9"
      @@formats['first'] = Proc.new {|data| data.to_s[0] }
    end

    @@formats['float'] = Proc.new {|data| data.to_f }
    @@formats['upcase'] = Proc.new {|data| data.to_s.upcase }
    @@formats['downcase'] = Proc.new {|data| data.to_s.downcase }
    @@formats['capitalize'] = Proc.new {|data| data.to_s.capitalize }
    @@formats['reverse'] = Proc.new {|data| data.to_s.reverse }
    @@formats['date'] = Proc.new {|data| Date.parse(data) rescue data }

    int_lookup = Hash.new {|hash, key| hash[key] = key.to_i }
    int_lookup[true] = 1
    int_lookup[false] = 0
    int_lookup[nil] = 0
    @@formats['integer'] = int_lookup

    @@formats['boolean'] = Hash.new {|hash, key|
      hash[key] = ['true', 't', 'yes', 'y', '1'].include?(key.to_s.downcase) }
  end
end
