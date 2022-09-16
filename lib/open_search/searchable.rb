module OpenSearch
  module Searchable
    extend ActiveSupport::Concern

    class_methods do
      attr_accessor :o_fields
      def o_searchable(&block)
        fields = SearchableFields.new
        fields.instance_exec(&block)
        @o_fields = fields.field_blocks
      end
    end

    def osearch_data
      self.class.o_fields.inject({class_name: self.class.name}) do |hash,kv|
        field_name, block = kv
        hash.merge field_name => self.instance_exec(&block)
      end
    end
  end
end