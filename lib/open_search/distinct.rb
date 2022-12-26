module OpenSearch
  class Distinct
    attr_accessor :dist_key, :options, :orders

    def initialize(dist_key)
      self.options = { dist_times: 1, dist_count: 1}
      self.dist_key = dist_key
    end
    # 无用
    def order_by(field, sorting = :asc)
      orders ||= []
      orders << "#{sorting.to_s == 'asc' ? '+' : '-'}#{field}"
    end

    def limit(num)
      self.options[:dist_count] = num
    end

    def to_query
      options.merge(dist_key: dist_key, orders: orders && orders.join(';'))
    end
  end
end
