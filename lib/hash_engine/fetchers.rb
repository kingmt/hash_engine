module HashEngine
  module Fetchers
    @@fetchers = {}

    def fetchers
      @@fetchers
    end

    def add_fetcher name, &block
      @@fetchers[name] = block
    end

    def valid_fetcher?(fetcher)
      fetchers.has_key?(fetcher)
    end

    def fetcher(type, field_data, customer_data)
      if valid_fetcher?(type)
        fetchers[type].call(field_data, customer_data)
      end
    end

    @@fetchers['input'] = Proc.new {|field, data| data[field] }
    @@fetchers['literal'] = Proc.new {|field, data| field }
    @@fetchers['data'] = Proc.new {|field, data| data.values_at(*field) }
  end
end
