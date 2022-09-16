module OpenSearch
  module QueryScope
    class Base
      attr_accessor :conds, :scopes, :select_fields, :orders,:config

      include ::OpenSearch::CondCombine
      include ::OpenSearch::FetchFields
      include ::OpenSearch::Paginate
      def initialize
        self.conds = []
        self.scopes = []
        self.select_fields = []
        self.orders = []
        self.config = ""
      end
    end

    class AndScope < Base
      attr_accessor :top_and

      def initialize(top_and: false)
        super()
        self.top_and = top_and
      end

      def to_query
        match_conds,filter_conds = conds.partition{|c| c.is_a?( QueryCond::Match)}
        
        sentences = []
        if self.top_and
          sentences << "query=(#{match_conds.map(&:to_query).join(' AND ')})" unless match_conds.empty?
          sentences << "filter=(#{filter_conds.map(&:to_query).join(' AND ')})" unless filter_conds.empty?
          sentences << "config=#{config}"
          sentences << "sort=#{order_phases}"
          "#{sentences.join('&&')}"
        else
          "(#{filter_conds.map(&:to_query).join(' AND ')})"
        end
      end

      def order_phases
        # orders << Sort::OrderBy.new('RANK','desc')
        orders.map(&:to_query).join(';')
      end

      def full_query
        raise "not top query scope" unless top_and
        {
          query: to_query,
          fetch_fields: to_select_fields
        }
      end
    end

    class OrScope < Base
      def to_query
        querys = conds.map(&:to_query)
        querys += scopes.map(&:to_query)
        "(#{querys.join(' OR ')})"
      end
    end
  end
end
