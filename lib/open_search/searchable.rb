module OpenSearch
  module Searchable
    extend ActiveSupport::Concern

    class_methods do
      attr_accessor :o_fields

      def o_searchable(&block)
        search_fields = SearchableFields.new
        search_fields.instance_exec(search_fields, &block)
        self.o_fields = search_fields.fields
      end
    end

    def osearch_data
      self.class.o_fields.inject({ class_name: self.class.name }) do |hash, kv|
        field_name, info = kv
        hash.merge field_name => instance_exec(&info[:block])
      end
    end

    protected

    def _to_ranges(field_type, field_name, block)
      raise 'not in integer/float/time,unsupported' unless %w[integer float time].include?(field_type)

      _block = (block || -> { send(field_name) })
      vals = instance_exec(&_block)
      if field_type == 'float'
        vals = _float_pre_ranges(vals)
      elsif field_type == 'time'
        vals = _time_pre_ranges(vals)
      end
      _bit_ranges(vals.sort)
    end

    def _float_pre_ranges(vals)
      vals.map { |v| v * 100.to_i }
    end

    def _time_pre_ranges(vals)
      vals.map(&:to_i)
    end

    def _bit_ranges(vals)
      pre = nil
      vals.each_with_object([]) do |v, nums|
        nums << (v | (pre << 32)) if pre
        pre = v
      end
    end
  end
end
