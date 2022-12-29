# OpenSearch

本gem为search service 服务提供查询dsl，使用类似sunspot的语法

# 使用方法

- 配置服务地址

```ruby
OpenSearch::Client.service_url = 'http://localhost:2222'
```

### 指定索引字段
- set_instance 指定实例名称
- set_table_name 指定表名（默认为class name复数形式）
- 有 integer（整型）,float（浮点型），time(时间类型)，text(全文索引)
- 与sunspot一样，可跟 方法名的symbol，可跟 block
- 数组类型增加 multiple: true

```ruby
class Product < OpenStruct
  include OpenSearch::Searchable
  include OpenSearch::Searcher

  o_searchable do
    set_instance 'icc_search_start' # open search 实例名称
    set_table_name 'products'
    integer :id 
    text :product_name
    text :model
    float :price
    time :publish_date
    integer :history_dates
    integer (:price_unit_ids), multiple: true do
      product.published_price_unit_ids if product.product_type != 2
    end
  end
end

```

### 搜索
- 语法与 sunspot类似, keywords 需指定索引名(:default，可以为示例的:product_name)
- 可使用any_of,all_of实现 嵌套查询
- with 查询 可以跟 值,array, range，以及 gteq ,lteq,gt,lt 为key的hash
- without 与with使用相似，意思相反
- order_by 实现排序，可多个
- field_select 为 返回 查询的字段，无此则按照 open search 设置的默认返回字段
- paginate 分页,指定页码，每页个数即可
- facet 实现分片统计,默认为count结果, agg_fun 可以指定 count(id)、sum(id)、max(id)、min(id)、distinct_count五种系统函数
- group  实现分组抽取功能，可不带block，也可带block指定order_by， limit

```ruby
aa = Product.o_search do |f|
  f.keywords(:default, '大型')
  f.any_of do |ff|
    ff.query(:publish_date, (0..1))
    ff.query(:publish_date, (3..5))
  end
  f.any_of do
    with :price, gteq: 2
    without :class_name, 'Xxxxxx'
  end
  f.order_by(:id, 'desc')
  f.order_by(:price, 'desc')
  # f.order_by_function('normalize', 'price', 10, 5,'desc')
  f.field_select(:id,:product_name, :price)
  f.paginate(page: 1, per_page: 2)
  f.facet(:id)
  f.group(:id) do
    order_by :id,:desc
    order_by :market_price, :asc
    limit  10
  end
  # f.facet(:product_id)
end

```

### 结果

aa.results
aa.
aa.facet(:firm_id)  返回 指定分组的统计结果，结果格式与sunspot一样
aa.total 返回 结果数量

aa.custom_results  返回 产品/公司/品牌 等 对应的 专门格式