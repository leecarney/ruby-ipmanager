module IpManager
  class Account < APIResource
    OBJECT_NAME = "account".freeze

    def self.resource_url
      "/user/"
    end

    def self.authenticate(params = {})
      opts = {"Authorization" => 'Basic ' + Base64.encode64("#{IpManager.api_username}:#{IpManager.api_password}").chop}
      resp, opts = request(:post, Account.resource_url, params, opts)
      obj = ListObject.construct_from(resp.data)

      return @token = obj[:data][:token]
    end

  end
end