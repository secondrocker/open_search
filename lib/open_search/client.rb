module OpenSearch
  class Client
    class << self
      def configure(&block)
        instance_exec(&block)
      end

      def instance
        return @instance if @instance

        @instance = Aliyun::Opensearch::Client.new('wdo_search')
      end

      %w[endpoint access_key_id access_key_secret].each do |method_name|
        define_method method_name do |value|
          Aliyun::Opensearch::Configuration.send("#{method_name}=", value)
        end
      end
    end
  end
end
