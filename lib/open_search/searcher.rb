module OpenSearch
  module Searcher
    
    extend ActiveSupport::Concern

    class_methods do
      def o_search(&block)
        query_scope = QueryScope::AndScope.new(top_and: true)
        query_scope.with('class_name', self.name)
        query_scope.instance_exec(query_scope,&block)
        puts query_scope.full_query
        Client.instance.search(**query_scope.full_query)
      end
    end

  end
end