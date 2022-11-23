require 'open_search'
require 'ostruct'

OpenSearch::Client.service_url = 'http://localhost:2222'

class Product < OpenStruct
  include OpenSearch::Searchable
  include OpenSearch::Searcher

  o_searchable do
    integer :id
    text :product_name
    text :model
    float :price
    time :publish_date
    integer :history_dates
  end
end

# class Price < OpenStruct
#   include OpenSearch::Searchable

#   o_searchable do
#     integer :id
#     integer :product_id
#     float :price_price
#     time :price_publish_date
#   end
# end

# prices = [1, 2, 3].map do |i|
#   Price.new(
#     id: 34, product_id: 34, price_price: i * 10, time: Time.now - 3600 * 24 * i
#   )
# end
pre = nil
nums = [2, 4, 6, 8, 33].each_with_object([]) do |m, arr|
  arr << (pre + (m << 32)) unless pre.nil?
  pre = m
end
product = Product.new(
  id: 34,
  product_name: '大型设备',
  model: 'DNA-005',
  price: 222_222.22,
  publish_date: [1, 2, 3, 4],
  history_dates: nums
)
OpenSearch::Client.instance.insert('products', product.osearch_data)

aa = Product.o_search do |f|
  f.keywords(:default, '大型')
  # f.any_of do |ff|
  #   ff.query(:publish_date, (0..1))
  #   ff.query(:publish_date, (3..5))
  # end
  # f.any_of do
  #   with :price, gteq: 2
  #   without :class_name, 'Xxxxxx'
  # end
  f.order_by(:id, 'desc')
  order_by(:price, 'desc')
  # f.order_by_function('normalize', 'price', 10, 5,'desc')
  f.select(:id)
  f.paginate(page: 1, per_page: 1)
  f.facet(:class_name)
  f.facet(:product_id)
end
pp aa.facet(:class_name)
pp aa.total
pp aa.results
