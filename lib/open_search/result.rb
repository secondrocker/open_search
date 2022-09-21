module OpenSearch
  class Result
    attr_accessor :search_scope

    def initialize(search_scope)
      self.search_scope = search_scope
    end

    def results
      raise 'not top level scope' unless search_scope.top_scope?

      pp search_scope.full_query unless @results
      @results ||= Client.instance.search(**search_scope.full_query)
    end

    def raw_results
      OpenStruct.new(
        total_count: total, per_page: search_scope.pager[:per_page],
        items: results.fetch('items', [])
      )
    end

    def facet(key)
      rows = (results.fetch('facet', []).find { |x| x['key'] == key.to_s } || {})['items'] || []
      rows = rows.map { |r| OpenStruct.new(r) }
      OpenStruct.new(rows: rows)
    end

    def total
      results['total']
    end
  end
end
