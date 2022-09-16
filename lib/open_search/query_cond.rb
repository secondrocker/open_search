module OpenSearch
  module QueryCond
    class Base
      attr_accessor :field, :value, :relation_and

      def initialize(field, value, relation_and: true)
        self.field = field
        self.value = value
        self.relation_and = relation_and
      end
    end

    class Equal < Base
      def to_query
        
        format_value = value.is_a?(String) ?  %Q{"#{value}"} : value
        if relation_and
          "#{field}= #{format_value}"
        else
          "#{field}!= #{format_value}"
        end
      end
    end

    class Match < Base
      def to_query
        if relation_and
          "#{field}: '#{value}'"
        else
          "NOT #{field}: '#{value}'"
        end
      end
    end

    class In < Base
      def to_query
        if relation_and
          "in(#{field},\"#{value.join('|')}\")"
        else
          "notin(#{field},\"#{value.join('|')}\")"
        end
      end
    end

    class Range
      attr_accessor :field, :params

      def initialize(field, params)
        self.field = field
        self.params = params
      end

      def to_query
        if params[:gteq] && params[:lteq]
          "#{field}: [#{params[:gteq]},#{params[:lteq]}]"
        elsif params[:gt] && params[:lteq]
          "#{field}: (#{params[:gt]},#{params[:lteq]}]"
        elsif params[:gt] && params[:lt]
          "#{field}: (#{params[:gt]},#{params[:lt]})"
        elsif params[:gteq] && params[:lt]
          "#{field}: [#{params[:gteq]},#{params[:lt]}]"
        elsif params[:gteq]
          "#{field} >= #{params[:gteq]}"
        elsif params[:gt]
          "#{field} > #{params[:gteq]}"
        elsif params[:lteq]
          "#{field} <= #{params[:gteq]}"
        elsif params[:lt]
          "#{field} < #{params[:lt]}"
        end
      end
    end
  end
end
