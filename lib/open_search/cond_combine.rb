module OpenSearch
  module CondCombine
    def with(field, value)
      filters << if value.is_a?(Hash)
                   if self.top_scope &&  field.to_s == 'price_publish_dates'
                    self.set_times(value[:gteq]) if value[:gteq]
                    self.set_times(nil,value[:lteq]) if value[:lteq]
                   end
                   QueryCond::Range.new(field, **value, fields: search_class.o_fields)
                 elsif value.is_a?(Range)
                  if self.top_scope &&  field.to_s == 'price_publish_dates'
                    self.set_times(value.min,value.max) if field.to_s == 'price_publish_dates'
                  end
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
      # current_scope.instance_exec(current_scope, &block)
      if block.arity > 0 
        block.call(current_scope)
      else
        ContextBoundDelegate.instance_eval_with_context(current_scope, &block)
      end
      scopes << current_scope
    end

    def any_of(&block)
      current_scope = ::OpenSearch::QueryScope::OrScope.new(super_scope: self)
      # current_scope.instance_exec(current_scope, &block)
      if block.arity > 0 
        block.call(current_scope)
      else
        ContextBoundDelegate.instance_eval_with_context(current_scope, &block)
      end
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
      self.distinct.instance_exec(self.distinct, &block) if block_given?
    end

    def set_custom_path(path)
      self.custom_path = path
    end
  end
end
