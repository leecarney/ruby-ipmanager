module IpManager
  class IpManagerObject
    include Enumerable

    def initialize(id = nil)
      id, @retrieve_params = Util.normalize_id(id)
      @values = {}
      # TODO move to apiresource
      @values[:id] = id if id
    end

    def initialize_from(values)
      update_attributes(values)
      self
    end

    def self.construct_from(values, opts = {})
      values = IpManager::Util.symbolize_names(values)
      new(values[:id]).send(:initialize_from, values)
    end

    def to_s(*_args)
      JSON.pretty_generate(to_hash)
    end


    def inspect
      id_string = respond_to?(:id) && !id.nil? ? " id=#{id}" : ""
      "#<#{self.class}:0x#{object_id.to_s(16)}#{id_string}> JSON: " + JSON.pretty_generate(@values)
    end

    def update_attributes(values, method_options = {})
      values.each do |k, v|
        @values[k] = Util.convert_to_ipmanager_object(v)
      end
    end

    def [](k)
      @values[k.to_sym]
    end

    def []=(k, v)
      send(:"#{k}=", v)
    end

    def keys
      @values.keys
    end

    def values
      @values.values
    end

    def to_json(*_a)
      JSON.generate(@values)
    end

    def as_json(*a)
      @values.as_json(*a)
    end

    def to_hash
      maybe_to_hash = lambda do |value|
        value && value.respond_to?(:to_hash) ? value.to_hash : value
      end

      @values.each_with_object({}) do |(key, value), acc|
        acc[key] = case value
                     when Array
                       value.map(&maybe_to_hash)
                     else
                       maybe_to_hash.call(value)
                   end
      end
    end

    def each(&blk)
      @values.each(&blk)
    end

    def serialize_params(options = {})
      update_hash = {}

      @values.each do |k, v|

        unsaved = @unsaved_values.include?(k)
        if options[:force] || unsaved || v.is_a?(IpManagerObject)
          update_hash[k.to_sym] =
              serialize_params_value(@values[k], @original_values[k], unsaved, options[:force], key: k)
        end
      end

      update_hash.reject! {|_, v| v.nil?}

      update_hash
    end
  end
end
