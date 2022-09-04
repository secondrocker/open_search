RSpec.describe OpenSearch do
  it 'has a version number' do
    expect(OpenSearch::VERSION).not_to be nil
  end
  context 'and scope' do
    let(:f) { OpenSearch::QueryScope::AndScope.new }
    it 'with conds' do
      f.with(:a, 1)
      f.with(:b, 2)
      expect(f.to_query).to eq("(a: '1' AND b: '2')")
    end
  end
end