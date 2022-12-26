module OpenSearch
  module Searcher
    extend ActiveSupport::Concern

    class_methods do
      def o_search(&block)
        query_scope = QueryScope::AndScope.new(top_scope: true, search_class: self)
        # query_scope.instance_exec(query_scope, &block)
        if block.arity > 0 
          block.call(query_scope)
        else
          ContextBoundDelegate.instance_eval_with_context(query_scope, &block)
        end
        ::OpenSearch::Result.new(query_scope)
      end
    end
  end
end
