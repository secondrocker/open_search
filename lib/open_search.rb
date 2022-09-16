require 'open_search/version'
require 'active_support'
require 'aliyun/opensearch'

module OpenSearch
  autoload :QueryCond, 'open_search/query_cond'
  autoload :CondCombine, 'open_search/cond_combine'
  autoload :FetchFields, 'open_search/fetch_fields'
  autoload :Paginate, 'open_search/paginate'
  autoload :QueryScope, 'open_search/query_scope'

  autoload :Client, 'open_search/client'
  autoload :Searchable, 'open_search/searchable'
  autoload :SearchableFields, 'open_search/searchable_fields'
  autoload :Searcher, 'open_search/searcher'
  autoload :Sort, 'open_search/sort'
end
