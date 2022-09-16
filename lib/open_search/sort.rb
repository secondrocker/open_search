module OpenSearch

  module Sort
    class OrderBy
      attr_accessor :field,:sorting
      def initialize(field,sorting='asc')
        raise "sorting only receive asc | desc" unless %w[asc desc].include?(sorting)
        self.field = field
        self.sorting = sorting
      end

      def to_query
        "#{sorting == 'asc' ? '+' : '-'}#{field}"
      end
    end

    class OrderByFunction
      attr_accessor :func, :params,:sorting
      def initialize(func,*params,sorting)
        raise "sorting only receive asc | desc" unless %w[asc desc].include?(sorting)

        self.func = func
        self.params = params
        self.sorting = sorting
      end

      def to_query
        "#{sorting == 'asc' ? '+' : '-'}#{func}(#{params.join(',')}) "
      end
    end
  end
end