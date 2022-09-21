module OpenSearch
  class SearchableFields
    attr_accessor :field_blocks

    def initialize
      @field_blocks = {}
    end

    %w[text integer float time string].each do |field_type|
      define_method field_type do |field_name, _options = {}, &block|
        @field_blocks[field_name] = (block || -> { send(field_name) })
      end
    end
  end
end
