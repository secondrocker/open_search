module OpenSearch
  module QueryScope
    class Base
      attr_accessor :filters, :scopes, :select_fields, :orders, :config, :queries, :top_scope, :facets, :pager,
                    :search_class, :distinct

      include ::OpenSearch::CondCombine
      include ::OpenSearch::FetchFields
      include ::OpenSearch::Paginate
      def initialize(top_scope: false, search_class: nil, super_scope: nil)
        self.search_class = search_class || super_scope&.search_class
        self.top_scope = top_scope
        self.filters = []
        self.scopes = []
        self.select_fields = []
        self.orders = []
        self.queries = []
        self.facets = []
        self.pager = {}
        self.config = ''
      end

      def top_scope?
        top_scope
      end
    end

    class AndScope < Base
      # def to_query
      #   query_scopes, filter_scopes = scopes.partition{|s| s.}
      #   query_conds = queries + scopes
      #   filter_conds = conds
      #   filter_conds += scopes
      #   sentences = []
      #   if self.top_scope?
      #     sentences << "query=(#{match_conds.map(&:to_query).join(' AND ')})" unless match_conds.empty?
      #     sentences << "filter=(#{filter_conds.map(&:to_query).join(' AND ')})" unless filter_conds.empty?
      #     sentences << "config=#{config}"
      #     sentences << "sort=#{order_phases}"
      #     "#{sentences.join('&&')}"
      #   else
      #     "(#{filter_conds.map(&:to_query).join(' AND ')})"
      #   end
      # end

      def to_query
        _queries = (queries + scopes).map(&:to_query).compact
        "(#{_queries.join(' AND ')})" unless _queries.empty?
      end

      def to_filter
        _filters = (filters + scopes).map(&:to_filter).compact
        "(#{_filters.join(' AND ')})" unless _filters.empty?
      end

      def order_phases
        # orders << Sort::OrderBy.new('RANK','desc')
        orders.map(&:to_query).join(';')
      end

      def full_query
        raise 'not top query scope' unless top_scope?

        {
          instance: search_class.o_instance,
          queries: to_query,
          filters: to_filter
          config: config
          fetch_fields: to_select_fields,
          sorts: order_phases,
          aggragate: facets.map(&:to_query),
          **(self.distinct ? { distinct: self.distinct.to_query} : {})
        }
      end
    end

    class OrScope < Base
      def to_query
        _queries = (queries + scopes).map(&:to_query).compact
        "(#{_queries.join(' OR ')})" unless _queries.empty?
      end

      def to_filter
        _filters = (filters + scopes).map(&:to_filter).compact
        "(#{_filters.join(' OR ')})" unless _filters.empty?
      end
    end
  end
end
