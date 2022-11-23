module OpenSearch
  class Distinct
    attr_accessor :dist_key, :options

    def initialize(dist_key)
      self.options = { dist_times: 1, dist_count: 3}
      self.group_key = group_key
    end
    # 无用
    def order_by

    end

    def limit(num)
      self.options[:dist_count] = num
    end

    def to_query
      options.merge(group_key: group_key)
    end
  end
end
