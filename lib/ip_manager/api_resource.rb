module IpManager
  class APIResource < IpManagerObject
    include IpManager::APIOperations::Request

    def self.class_name
      name.split("::")[-1]
    end

    def self.resource_url
      if self == APIResource
        raise NotImplementedError, "APIResource is an abstract class."
      end
    end

    def resource_url
      unless (id = self["id"])
        raise InvalidRequestError.new("Could not determine which URL to request: #{self.class}", "id")
      end
      "#{self.class.resource_url}/#{CGI.escape(id)}"
    end

    def self.retrieve(id, opts = {})
      opts = Util.normalize_opts(opts)
      instance = new(id, opts)
      instance.refresh
      instance
    end
  end
end
