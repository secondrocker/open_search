module OpenSearch
  class Client
    class << self
      attr_accessor :service_url

      def push_index(instance, table_name, records)
        return if !records || records.size == 0
        request('/index/push', {
          instance: instance,
          table_name: table_name,
          records: records.to_json
        })
      end

      def request(path, params = {})
        raise "search service url not set!" if service_url.nil?
        res = RestClient.post(service_url+ path, params)
        JSON.parse(res.body)
      end

      # def conn
      #   @conn ||= Faraday.new(service_url) do |f|
      #     f.request :json
      #     f.request :retry
      #     f.response :json
      #   end
      # end
    end
  end
end
