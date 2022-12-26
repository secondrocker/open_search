module OpenSearch
  class ContextBoundDelegate
    class <<self
      def instance_eval_with_context(receiver, &block)
        calling_context = eval('self', block.binding)
        if parent_calling_context = calling_context.instance_eval{@__calling_context__ if defined?(@__calling_context__)}
          calling_context = parent_calling_context
        end
        new(receiver, calling_context).instance_eval(&block)
      end
      private :new
    end

    BASIC_METHODS = Set[:==, :equal?, :"!", :"!=", :instance_eval,
                        :object_id, :__send__, :__id__]

    instance_methods.each do |method|
      unless BASIC_METHODS.include?(method.to_sym)
        undef_method(method)
      end
    end

    def initialize(receiver, calling_context)
      @__receiver__, @__calling_context__ = receiver, calling_context
    end

    def id
      begin
        @__calling_context__.__send__(:id)
      rescue ::NoMethodError => e
        begin
          @__receiver__.__send__(:id)
        rescue ::NoMethodError
          raise(e)
        end
      end
    end

    # Special case due to `Kernel#sub`'s existence
    def sub(*args, &block)
      __proxy_method__(:sub, *args, &block)
    end

    def method_missing(method, *args, &block)
      __proxy_method__(method, *args, &block)
    end

    def __proxy_method__(method, *args, &block)
      begin
        @__receiver__.__send__(method.to_sym, *args, &block)
      rescue ::NoMethodError => e
        begin
          @__calling_context__.__send__(method.to_sym, *args, &block)
        rescue ::NoMethodError
          raise(e)
        end
      end
    end
  end
end