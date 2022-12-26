module OpenSearch
  class Facet
    attr_accessor :group_key, :options

    def initialize(group_key, options = {})
      options[:agg_funcs] ||= ['count()']
      self.group_key = group_key
      self.options = options
    end

    def to_query
      options.merge(group_key: group_key)
    end
  end
end
