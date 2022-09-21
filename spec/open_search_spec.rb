RSpec.describe OpenSearch do
  it 'has a version number' do
    expect(OpenSearch::VERSION).not_to be nil
  end
  context 'and scope' do
    let(:f) { OpenSearch::QueryScope::AndScope.new }
    it 'with conds' do
      f.with(:a, 1)
      f.with(:b, 2)
      expect(f.to_filter).to include('(a= 1 AND b= 2)')
    end
  end

  context 'or scope' do
    let(:f) { OpenSearch::QueryScope::AndScope.new }
    it 'with conds' do
      f.any_of do |ff|
        ff.with(:a, 1)
        ff.with(:b, 2)
      end
      expect(f.to_filter).to include('(a= 1 OR b= 2)')
    end
  end

  context 'or query scope' do
    let(:f) { OpenSearch::QueryScope::AndScope.new }
    it 'with conds' do
      f.any_of do |ff|
        ff.keywords(:a, 'a')
        ff.query(:b, (1..3))
      end
      expect(f.to_query).to include('(a: a OR b: [1,3])')
    end
  end
end
