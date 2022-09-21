module OpenSearch
  class Facet
    attr_accessor :key, :options

    def initialize(key, options = {})
      options[:agg_fun] ||= 'count()'
      self.key = key
      self.options = options
    end

    def to_facet
      "group_key:#{key},agg_fun:#{options[:agg_fun]}"
    end
  end
end
