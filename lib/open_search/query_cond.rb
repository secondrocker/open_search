module OpenSearch
  module QueryCond
    class Base
      attr_accessor :field, :value, :relation_and, :fields

      def initialize(field, value, relation_and: true, fields: [])
        self.fields = fields
        self.field = field.to_sym
        self.value = value
        self.relation_and = relation_and
      end
    end

    class Equal < Base
      def to_filter
        format_value = value.is_a?(String) ? %("#{value}") : value
        format_value = value.to_i if self.fields[field][:field_type] == 'time'
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
      def to_filter
        if self.fields[field][:multiple]
          value = self.value.map(&to_i) if self.fields[field][:field_type] == 'time'
          vv = value.map{|v| "#{field}#{relation_and ? '=' : '!='}#{v}"}.join(" AND ")
          "(#{vv})"
        else
          "#{relation_and ? 'in' : 'notin'}(#{field},\"#{self.value.join('|')}\")"
        end
      end
    end

    class Range
      attr_accessor :field, :params

      RANGE_SYMS = {
        gteq: '>=',
        lteq: '<=',
        gt: '>',
        lt: '<'
      }
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
          "#{field}: [#{params[:gteq]},)"
        elsif params[:gt]
          "#{field}:  (#{params[:gteq]},)"
        elsif params[:lteq]
          "#{field}:  (,#{params[:gteq]}]"
        elsif params[:lt]
          "#{field} < (,#{params[:lt]})"
        end
      end

      def to_filter
        o_field = params[:fields][field]
        return normal_filter unless o_field[:multiple]
        raise 'multiple support int/float/time only!' unless %w[int float time].include?(o_field[:field_type])

        if o_field[:field_type] == 'float'
          min = ((params[:gteq] || params[:gt] || -42_949_672) * 100).to_i # 32 位能表达最小的负数/100
          max = ((params[:lteq] || params[:lt] || 85_899_345) * 100).to_i # 32 位能表达最大的数/100
        elsif o_field[:field_type] == 'time'
          min = (params[:gteq] || params[:gt] || 0).to_i # 1970年 秒数
          max = (params[:lteq] || params[:lt] || 8_589_934_592).to_i # 2242年秒数
        else
          min = (params[:gteq] || params[:gt] || -4_294_967_296).to_i
          max = (params[:lteq] || params[:lt] || 8_589_934_592).to_i
        end
        min += 1 if params[:gt]
        max -= 1 if params[:lt]
        _field = "#{self.field}_arr_" # 数组 范围查询字段
        <<-STR
          bit_struct(#{_field},"0-31,32-63", "overlap,$1,$2,#{min},#{max}") != -1
        STR
      end

      def normal_filter
        ff = %i[gteq gt lteq lt].each_with_object([]) do |key, ss|
          ss << "#{field} #{RANGE_SYMS[key]} #{params[key]}" if params[key]
        end
        return ff if ff.size == 1

        "(#{ff.join(' AND ')})"
      end
    end
  end
end
