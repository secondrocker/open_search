module OpenSearch
  module FetchFields
    def select(*args)
      self.select_fields += args
    end

    def to_select_fields
      self.select_fields.join(';')
    end
  end
end
