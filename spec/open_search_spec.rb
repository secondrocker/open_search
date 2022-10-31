class TestModel < OpenStruct
  include OpenSearch::Searchable

  o_searchable do
    integer :a
    float :b
    text :x
    time :tt, multiple: true
    float :ff, multiple: true do
      ff.map { |x| x * 3 }
    end
  end
end
RSpec.describe OpenSearch do
  it 'has a version number' do
    expect(OpenSearch::VERSION).not_to be nil
  end
  let!(:m) { TestModel.new(a: 1, b: 2, x: 'x', tt: [Time.local(2022, 3, 1), Time.local(2022, 4, 5)], ff: [2, 1, 3]) }
  context 'and scope' do
    let(:f) { OpenSearch::QueryScope::AndScope.new(search_class: TestModel) }
    it 'with conds' do
      f.with(:a, 1)
      f.with(:b, 2)
      expect(f.to_filter).to include('(a= 1 AND b= 2)')
    end
  end

  context 'or scope' do
    let(:f) { OpenSearch::QueryScope::AndScope.new(search_class: TestModel) }
    it 'with conds' do
      f.any_of do |ff|
        ff.with(:a, 1)
        ff.with(:b, 2)
      end
      expect(f.to_filter).to include('(a= 1 OR b= 2)')
    end
  end

  context 'range' do
    let(:f) { OpenSearch::QueryScope::AndScope.new(search_class: TestModel) }
    it 'range scope' do
      f.any_of do |ff|
        ff.with(:a, gteq: 2, lteq: 4)
        ff.with(:b, lt: 4)
      end
      expect(f.to_filter).to include('(a >= 2 AND a <= 4) OR b < 4')
    end
  end

  context 'or query scope' do
    let(:f) { OpenSearch::QueryScope::AndScope.new(search_class: TestModel) }
    it 'with conds' do
      f.any_of do |ff|
        ff.keywords(:x, 'x')
        ff.with(:b, (1..3))
      end
      expect(f.to_filter).to include('(b >= 1 AND b <= 3)')
      expect(f.to_query).to include('x: x')
    end
  end

  context 'bit_struct' do
    it 'search model data' do
      data = m.osearch_data
      a1 = m.tt.first.to_i
      a2 = m.tt.last.to_i
      expect(data[:tt]).to eq([(a1 << 32) | a2])
      m.ff.sort!
      f1 = m.ff[0] * 3 * 100
      f2 = m.ff[1] * 3 * 100
      f3 = m.ff[2] * 3 * 100
      expect(data[:ff]).to eq([(f1 << 32) | f2, (f2 << 32 | f3)])
    end
    let(:f) { OpenSearch::QueryScope::AndScope.new(search_class: TestModel) }
    it 'search bit_struct' do
      f.any_of do |ff|
        ff.with(:tt, gteq: Time.local(2022, 4, 1))
        ff.with(:ff, gt: 3, lteq: 5)
      end
      expect(f.to_filter).to include(Time.local(2022, 4, 1).to_i.to_s)
      expect(f.to_filter).to include(301.to_s)
      expect(f.to_filter).to include(500.to_s)
      expect(f.to_filter).to include('bit_struct')
    end
  end
end
