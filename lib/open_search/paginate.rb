module OpenSearch
  module Paginate
    def paginate(page: 1, per_page: 20)
      self.pager = { page: page, per_page: per_page }
      self.config = Config.new(start: (page - 1) * per_page,hit: per_page)
    end

    class Config
      attr_accessor :options
      def initialize(options)
        self.options = options
      end
    end
  end
end
