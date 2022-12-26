module OpenSearch
  module FetchFields
    def field_select(*args)
      self.select_fields += args
    end

    def to_select_fields
      self.select_fields
    end
  end
end
