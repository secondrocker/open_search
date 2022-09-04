module OpenSearch
  module FetchFields
    def select(*args)
      self.select_fields += args
    end

    def to_select_fields
      self.select_fields.join(';')
    end
  end

  module OrderFields
    def order_by(field, sort_type = :asc)
      order_fields << { field: field, sort_type: sort_type }
    end

    def to_order_fields
      order_fields.map do |f|
        "#{f[:sort_type] == :asc ? '+' : '-'}#{f[:field]}"
      end.join(';')
    end
  end

  module Paginate
    def paginate(page: 1, per_page: 20); end
  end
end
