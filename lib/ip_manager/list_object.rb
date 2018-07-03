module IpManager
  class ListObject < IpManagerObject
    include Enumerable
    include IpManager::APIOperations::List
    include IpManager::APIOperations::Request
    include IpManager::APIOperations::Create

    OBJECT_NAME = "list".freeze

    attr_accessor :filters

    def self.empty_list(opts = {})
      ListObject.construct_from({ data: [] }, opts)
    end

    def initialize(*args)
      super
      self.filters = {}
    end

    def empty?
      data.empty?
    end

    def retrieve(opts = {})
      resp, opts = request(:get, "#{resource_url}", retrieve_params, opts)
      Util.convert_to_ipmanager_object(resp.data, opts)
    end

    def resource_url
      url ||
        raise(ArgumentError, "List object does not contain a 'url' field.")
    end
  end
end
