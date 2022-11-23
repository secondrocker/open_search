module OpenSearch
  module CondCombine
    def with(field, value)
      filters << if value.is_a?(Hash)
                   QueryCond::Range.new(field, **value, fields: search_class.o_fields)
                 elsif value.is_a?(Range)
                   QueryCond::Range.new(field, gteq: value.min, lteq: value.max, fields: search_class.o_fields)
                 elsif value.is_a?(Array)
                   QueryCond::In.new(field, value, fields: search_class.o_fields)
                 else
                   QueryCond::Equal.new(field, value, fields: search_class.o_fields)
                 end
    end

    def without(field, value)
      raise 'without not support range,use with' if value.is_a?(Hash) || value.is_a?(Range)

      filters << if value.is_a?(Array)
                   QueryCond::In.new(field, value, relation_and: false, fields: search_class.o_fields)
                 else
                   QueryCond::Equal.new(field, value, relation_and: false, fields: search_class.o_fields)
                 end
    end

    def keywords(field, value)
      # raise "only top scope receive keywords" unless top_scope?

      queries << QueryCond::Match.new(field, value, fields: search_class.o_fields)
    end

    def query(field, value)
      # raise "only top scope receive keywords" unless top_scope?

      filters << if value.is_a?(Hash)
                   QueryCond::Range.new(field, **value, fields: search_class.o_fields)
                 elsif value.is_a?(Range)
                   QueryCond::Range.new(field, gteq: value.min, lteq: value.max, fields: search_class.o_fields)
                 else
                   raise 'not support'
                 end
    end

    def all_of(&block)
      current_scope = ::OpenSearch::QueryScope::AndScope.new(super_scope: self)
      current_scope.instance_exec(current_scope, &block)
      scopes << current_scope
    end

    def any_of(&block)
      current_scope = ::OpenSearch::QueryScope::OrScope.new(super_scope: self)
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

    def group(dist_key, &block)
      self.distinct = Distinct.new(dist_key)
      se.fldistinct.instance_exec(&block)
    end
  end
end
