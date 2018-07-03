module IpManager
  class Section < APIResource
    extend IpManager::APIOperations::List
    OBJECT_NAME = "section".freeze

    def self.resource_url
      "/sections/"
    end

    def self.section_data_resource_url
      "/sections"
    end

    def self.sections_data
      sections_list = Section.list(section_data_resource_url)[:data]
      sections_list.each do |section|
        @sections_list = Section.list(resource_url + "#{section[:id]}/subnets")[:data]
      end
      @sections_list
    end

  end
end

