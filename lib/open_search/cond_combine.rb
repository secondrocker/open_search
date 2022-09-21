module OpenSearch
  module CondCombine
    def with(field, value)
      filters << if value.is_a?(Hash)
                   QueryCond::Range.new(field, **value)
                 elsif value.is_a?(Range)
                   QueryCond::Range.new(field, gteq: value.min, lteq: value.max)
                 elsif value.is_a?(Array)
                   QueryCond::In.new(field, value)
                 else
                   QueryCond::Equal.new(field, value)
                 end
    end

    def without(field, value)
      raise 'without not support range,use with' if value.is_a?(Hash) || value.is_a?(Range)

      filters << if value.is_a?(Array)
                   QueryCond::In.new(field, value, relation_and: false)
                 else
                   QueryCond::Equal.new(field, value, relation_and: false)
                 end
    end

    def keywords(field, value)
      # raise "only top scope receive keywords" unless top_scope?

      queries << QueryCond::Match.new(field, value)
    end

    def query(field, value)
      # raise "only top scope receive keywords" unless top_scope?

      queries << if value.is_a?(Hash)
                   QueryCond::Range.new(field, **value)
                 elsif value.is_a?(Range)
                   QueryCond::Range.new(field, gteq: value.min, lteq: value.max)
                 else
                   raise 'not support'
                 end
    end

    def all_of(&block)
      current_scope = ::OpenSearch::QueryScope::AndScope.new
      current_scope.instance_exec(current_scope, &block)
      scopes << current_scope
    end

    def any_of(&block)
      current_scope = ::OpenSearch::QueryScope::OrScope.new
      current_scope.instance_exec(current_scope, &block)
      scopes << current_scope
    end

    def order_by(field, sorting = 'asc')
      orders << Sort::OrderBy.new(field, sorting)
    end

    def order_by_function(*params)
      orders << Sort::OrderByFunction.new(*params)
    end

    def facet(key, options: {})
      facets << Facet.new(key, options)
    end
  end
end
