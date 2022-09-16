require 'open_search'
require 'ostruct'

OpenSearch::Client.configure do
  endpoint  'opensearch-cn-shenzhen.aliyuncs.com'
  access_key_id  'aaa'
  access_key_secret  'bbb'
end

class Product < OpenStruct
  include OpenSearch::Searchable
  include OpenSearch::Searcher

  o_searchable do
    integer :id
    text :product_name
    text :category_text
    text :model
    float :price
    time :publish_date
    integer :history_dates
  end
end

class Price < OpenStruct
  include OpenSearch::Searchable

  o_searchable do
    integer :id
    integer :product_id
    float :price_price
    time :price_publish_date
  end
end

prices = [1,2,3].map do |i|
  Price.new(
    id: i,product_id: 34,price_price: i*10,time: Time.now - 3600 * 24 * i
  )
end

# product = Product.new(
#   id: 34,
#   product_name: '大型设备',
#   category_text: 'DNA检查 核酸检查 大型设备',
#   model: 'DNA-005',
#   price: 222222.22,
#   publish_date: Time.now.to_s,
#   history_dates: [1,2,3,4,5]
# )
# OpenSearch::Client.instance.update('products', product.osearch_data)

 aa= Product.o_search do |f|
    f.keywords(:default, '大型')
    f.with(:price_price, gteq: 20)
    f.with(:price, gteq: 12)
    f.with(:history_dates, 2)
    f.order_by(:id,'desc')
    f.order_by(:price,'desc')
    f.select(:id,:model,:product_name)
    f.paginate(page: 1,per_page: 2)
  end
pp aa