module OpenSearch
  class SearchableFields
    attr_accessor :fields, :instance, :primary_key, :table_name

    def initialize
      @fields = {}
    end

    %i[instance primary_key table_name].each do |name|
      define_method "set_#{name}" do |val|
        instance_variable_set("@#{name}".to_sym, val)
      end
    end

    %w[text integer float time string].each do |field_type|
      define_method field_type do |field_name, _options = {}, &block|
        field_name = field_name.to_sym
        base_field = {
          field_type: field_type,
          multiple: _options[:multiple]
        }
        if _options[:multiple]
          @fields[(field_name.to_s + '_arr_').to_sym]  = base_field.merge(block: -> { _to_ranges(field_type, field_name, block) })
          @fields[field_name] = base_field.merge(block: -> {
            _block = block || -> { send(field_name) }
            rtn = instance_exec(&_block)
            rtn && field_type == 'time' ?  rtn.map(&:to_i) : rtn
          })
        else
          @fields[field_name]= base_field.merge(block: -> {
            _block = block || -> { send(field_name) }
            rtn = instance_exec(&_block)
            rtn && field_type == 'time' ?  rtn.to_i : rtn
          })
        end
      end
    end
  end
end
