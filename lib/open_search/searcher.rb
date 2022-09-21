module OpenSearch
  module Searcher
    extend ActiveSupport::Concern

    class_methods do
      def o_search(&block)
        query_scope = QueryScope::AndScope.new(top_scope: true)
        query_scope.with('class_name', name)
        query_scope.instance_exec(query_scope, &block)
        ::OpenSearch::Result.new(query_scope)
      end
    end
  end
end
