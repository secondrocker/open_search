require_relative './lib/open_search.rb'

OpenSearch::Client.service_url = 'http://localhost:2222'

class Product < OpenStruct
  include OpenSearch::Searchable
  include OpenSearch::Searcher

  o_searchable do
    set_instance 'icc_search_start'

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
# Product.push_index([product])
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
  f.order_by(:price, 'desc')
  # f.order_by_function('normalize', 'price', 10, 5,'desc')
  f.field_select(:id,:product_name, :price)
  f.paginate(page: 1, per_page: 2)
  f.facet(:id)
  f.group(:id) do

  end
  # f.facet(:product_id)
end
# pp aa.facet(:class_name)
# pp aa.total
# pp aa.results
aa.results


aa = FirmProduct.o_search do |f|
  set_custom_path('common')
  keywords(:firm_id,15686)

end
word ="水泥"
OpenSearch::Client.service_url = 'http://localhost:19945'
aa = FirmProduct.o_search do |f|
  f.set_custom_path('product')
  f.keywords(:default,word)
  f.group(:firm_id)
  f.facet(:category_id)
  f.facet(:product_type)
  f.facet(:brand_id)
  f.facet(:firm_id)
  f.field_select(:firm_id,:id,:category_id,:brand_id)
  f.paginate(page: 1, per_page: 10)
end


aa = FirmProduct.o_search do
  set_custom_path('product')
  keywords(:default,word)
  group(:firm_id)
  facet(:category_id)
  facet(:product_type)
  facet(:brand_id)
  facet(:firm_id)
  field_select(:firm_id,:id,:category_id,:brand_id)
  paginate(page: 1, per_page: 10)
end


FirmProduct.includes([:product=>[:new_price,:product_category,:last_price,:information_price,:brand,:batch_product_picture,:last_market_price,:last_project_price,:product_parameters],:firm=>[:alias_firms]]).find_in_batches(:batch_size => 100, start: 664841) do |ff|
  FirmProduct.push_index(ff)
end

Ora::ProductCategory.find_in_batches(batch_size: 100) do |cc|
  Ora::ProductCategory.push_index(cc)
end

Ora::Brand.find_in_batches(batch_size: 100) do |cc|
  Ora::Brand.push_index(cc)
end

