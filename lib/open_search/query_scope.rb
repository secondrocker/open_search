module OpenSearch
  module QueryScope
    class Base
      attr_accessor :conds, :scopes, :select_fields, :order_fields

      include ::OpenSearch::CondCombine
      include ::OpenSearch::FetchFields
      include ::OpenSearch::OrderFields
      def initialize
        self.conds = []
        self.scopes = []
        self.select_fields = []
        self.order_fields = []
      end
    end

    class AndScope < Base
      def to_query
        querys = conds.map(&:to_query)
        querys += scopes.map(&:to_query)
        "(#{querys.join(' AND ')})"
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
