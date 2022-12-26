require_relative 'open_search/version.rb'
require 'active_support'
require 'active_support/inflector'
require 'ostruct'
# require 'faraday'
# require 'faraday/retry'

lib = File.expand_path('../', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

module OpenSearch
  autoload :QueryCond, 'open_search/query_cond'
  autoload :CondCombine, 'open_search/cond_combine'
  autoload :FetchFields, 'open_search/fetch_fields'
  autoload :Paginate, 'open_search/paginate'
  autoload :QueryScope, 'open_search/query_scope'
  
  autoload :Client, 'open_search/client'
  autoload :ContextBoundDelegate, 'open_search/context_bound_delegate'
  autoload :Searchable, 'open_search/searchable'
  autoload :SearchableFields, 'open_search/searchable_fields'
  autoload :Searcher, 'open_search/searcher'
  autoload :Sort, 'open_search/sort'
  autoload :Facet, 'open_search/facet'
  autoload :Distinct, 'open_search/distinct'
  autoload :Result, 'open_search/result'
end
