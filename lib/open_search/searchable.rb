module OpenSearch
  module Searchable
    extend ActiveSupport::Concern

    class_methods do
      attr_accessor :o_fields
      attr_accessor :o_instance
      attr_accessor :o_primary_key
      attr_accessor :o_table_name

      def o_searchable(&block)
        search_fields = SearchableFields.new
        search_fields.instance_exec(search_fields, &block)
        self.o_fields = search_fields.fields
        self.o_instance = search_fields.instance
        self.o_primary_key = search_fields.primary_key || 'id' # 默认主键为id
        self.o_table_name = search_fields.table_name || self.name.tableize
        raise "must set instance" if self.o_instance.nil?
      end

      def remove_index(ids)
        records = ids.map do |id|
          {
            cmd: 'delete',
            fields: {
              self.o_primary_key => id
            }
          }
        end
        ::OpenSearch::Client.remove_index(self.o_instance, self.o_table_name,records)
      end

      def push_index(records)
        # primary_key = self.o_primary_key.to_s
        records.each_slice(100) do |_records|
          # rr = self.o_search do 
          #   any_of do
          #     _records.each do |r|
          #       keywords(primary_key, r.send(primary_key))
          #     end
          #   end
          #   select(primary_key)
          # end.results
          # primary_ids = rr.fetch('items', []).map{|r| r[primary_key]}
          items = _records.map do |r|
            {
              cmd: 'add',
              fields: r.osearch_data
            }
          end
          ::OpenSearch::Client.push_index(self.o_instance, self.o_table_name, items)
        end
        
      end
    end

    def osearch_data
      self.class.o_fields.inject({}) do |hash, kv|
        field_name, info = kv
        hash.merge field_name => instance_exec(&info[:block])
      end
    end

    protected

    def _to_ranges(field_type, field_name, block)
      raise 'not in integer/float/time,unsupported' unless %w[integer float time].include?(field_type)

      _block = (block || -> { send(field_name) })
      vals = instance_exec(&_block)
      return if vals.nil?

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
