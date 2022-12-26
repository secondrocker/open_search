module OpenSearch
  class Result
    attr_accessor :search_scope

    def initialize(search_scope)
      self.search_scope = search_scope
    end

    def type_cast(value,field) 
      value = value.to_s.split("\t") if field[:multiple]
      case field[:field_type]
      when 'float'
        field[:multiple] ? value.map(&:to_f) : value.to_f
      when 'integer'
        field[:multiple] ? value.map(&:to_i) : value.to_i
      when 'time'
        field[:multiple] ? value.map{|v| Time.at(v.to_i)} : Time.at(value.to_i)
      else
        value
      end
    end

    def custom_results
      raise 'not top level scope' unless search_scope.top_scope?
      pp search_scope.full_query unless @custom_results
      hash = { query: search_scope.full_query.to_json }
      hash.merge! start_time: search_scope.start_time if search_scope.start_time
      hash.merge! end_time: search_scope.end_time if search_scope.end_time
      hash.merge! contain_tax: 'yes'#search_scope.contain_tax if search_scope.contain_tax
      @custom_results ||= Client.request(search_scope.service_path, **hash)
    end

    def results
      raise 'not top level scope' unless search_scope.top_scope?

      pp search_scope.full_query unless @results
      _results ||= Client.request(search_scope.service_path, query: search_scope.full_query.to_json)
      Array(_results['items']).each do |item|
        item.keys.each do |k|
          field = search_scope.search_class.o_fields[k.to_sym]
          item[k] = nil if item[k] == ""
          # if /_arr_$/ =~ k
          #   val = item.delete(k)
          #   k = k.gsub(/_arr_$/,'')
          #   item[k] = val
          # end
          if field && item[k]
            item[k]= type_cast(item[k], field)
          end
        end
      end
      @results = _results
    end

    def raw_results
      OpenStruct.new(
        total_count: total, per_page: search_scope.pager[:per_page],
        items: results.fetch('items', [])
      )
    end

    def facet(key)
      rows = (results.fetch('facet', []).find { |x| x['key'] == key.to_s } || {})['items'] || []
      rows = rows.map { |r| OpenStruct.new(r) }
      OpenStruct.new(rows: rows)
    end

    def total
      results['total']
    end
  end
end
