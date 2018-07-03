module IpManager
  module APIOperations
    module Request
      module ClassMethods
        def request(method, url, params = {}, opts = {})

          #opts = Util.normalize_opts(opts)
          opts[:client] ||= IpManagerClient.active_client

          headers = opts.clone
          api_base = headers.delete(:api_base)
          client = headers.delete(:client)
          # Assume all remaining opts must be headers
          resp, opts = client.execute_request(
            method, url,
            api_base: api_base,
            headers: headers, params: params
          )

          [resp]
        end

        private

      end

      def self.included(base)
        base.extend(ClassMethods)
      end

      protected

      def request(method, url, params = {}, opts = {})
        #opts = @opts.merge(Util.normalize_opts(opts))
        self.class.request(method, url, params, opts)
      end
    end
  end
end
