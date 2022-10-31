module OpenSearch
  class SearchableFields
    attr_accessor :fields

    def initialize
      @fields = {}
    end

    %w[text integer float time string].each do |field_type|
      define_method field_type do |field_name, _options = {}, &block|
        base_field = {
          field_type: field_type,
          multiple: _options[:multiple]
        }
        @fields[field_name] = if _options[:multiple]
                                base_field.merge(block: -> { _to_ranges(field_type, field_name, block) })
                              else
                                base_field.merge(block: (block || -> { send(field_name) }))
                              end
      end
    end
  end
end
