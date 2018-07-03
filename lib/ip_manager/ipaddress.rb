module IpManager
  class IpAddress < APIResource
    extend IpManager::APIOperations::Create

    OBJECT_NAME = "ipaddress".freeze

    def self.resource_url
      "/addresses/first_free/"
    end

    def self.allocate_ip(params)
      all_subnets = Section.sections_data
      all_subnets.each do |subnet|
        if subnet[:description] == (params[:subnet_target])
          @result = subnet
        end
      end
      obj = IpAddress.create(resource_url + "#{@result[:id]}?hostname=#{params[:hostname_tag]}&owner=#{params[:owner_tag]}")
      puts obj
    end

  end
end
