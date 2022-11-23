module OpenSearch
  class Client
    class << self
      attr_accessor :service_url

      def push_index(instance, table_name, records)
        return if !records || records.size == 0
        request('/index/push', {
          instance: instance,
          table_name: table_name,
          records: records
        })
      end

      def request(path, params)
        conn.post(path) do |req|
          req.params = params
        end
      end

      def conn
        @conn ||= Faraday.new(service_url) do |f|
          f.request :json
          f.request :retry
          f.response :json
        end
      end
    end
  end
end
