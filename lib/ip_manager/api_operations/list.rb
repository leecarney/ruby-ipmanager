module IpManager
  module APIOperations
    module List
      def list(params = {})
        resp, opts = request(:get, params)
        obj = ListObject.construct_from(resp.data)
      end
    end
  end
end
