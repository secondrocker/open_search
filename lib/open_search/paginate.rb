module OpenSearch
  module Paginate
    def paginate(page: 1, per_page: 20)
      self.pager = { page: page, per_page: per_page }
      self.config = "start:#{(page - 1) * per_page},hit:#{per_page}"
    end
  end
end
