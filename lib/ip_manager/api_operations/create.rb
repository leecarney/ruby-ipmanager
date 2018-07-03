module IpManager
  module APIOperations
    module Create
      def create(params = {})
        resp, opts = request(:post, params)
        obj = Util.convert_to_ipmanager_object(resp.data)
      end
    end
  end
end
