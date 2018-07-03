require "cgi"
require "openssl"

module IpManager
  module Util

    # Options that should be copyable from one IpManagerObject to another
    OPTS_COPYABLE = Set[:api_base].freeze

    def self.objects_to_ids(h)
      case h
      when APIResource
        h.id
      when Hash
        res = {}
        h.each {|k, v| res[k] = objects_to_ids(v) unless v.nil?}
        res
      when Array
        h.map {|v| objects_to_ids(v)}
      else
        h
      end
    end

    def self.object_classes
      @object_classes ||= {
          # data structures
          ListObject::OBJECT_NAME => ListObject,

          # business objects
          IpAddress::OBJECT_NAME => IpAddress,
          Account::OBJECT_NAME => Account,
          Section::OBJECT_NAME => Section,
      }
    end

    def self.convert_to_ipmanager_object(data, opts = {})
      case data
      when Array
        data.map {|i| convert_to_ipmanager_object(i, opts)}
      when Hash
        # Try converting to a known object class.  If none available, fall back to generic IpManagerObject
        object_classes.fetch(data[:object], IpManagerObject).construct_from(data, opts)
      else
        data
      end
    end

    def self.log_error(message, data = {})
      if !IpManager.logger.nil? ||
          !IpManager.log_level.nil? && IpManager.log_level <= IpManager::LEVEL_ERROR
        log_internal(message, data, color: :cyan,
                     level: IpManager::LEVEL_ERROR, logger: IpManager.logger, out: $stderr)
      end
    end

    def self.log_info(message, data = {})
      if !IpManager.logger.nil? ||
          !IpManager.log_level.nil? && IpManager.log_level <= IpManager::LEVEL_INFO
        log_internal(message, data, color: :cyan,
                     level: IpManager::LEVEL_INFO, logger: IpManager.logger, out: $stdout)
      end
    end

    def self.log_debug(message, data = {})
      if !IpManager.logger.nil? ||
          !IpManager.log_level.nil? && IpManager.log_level <= IpManager::LEVEL_DEBUG
        log_internal(message, data, color: :blue,
                     level: IpManager::LEVEL_DEBUG, logger: IpManager.logger, out: $stdout)
      end
    end

    def self.symbolize_names(object)
      case object
      when Hash
        new_hash = {}
        object.each do |key, value|
          key = (
          begin
            key.to_sym
          rescue StandardError
            key
          end) || key
          new_hash[key] = symbolize_names(value)
        end
        new_hash
      when Array
        object.map {|value| symbolize_names(value)}
      else
        object
      end
    end

    # Encodes a hash of parameters in a way that's suitable for use as query
    # parameters in a URI or as form parameters in a request body. This mainly
    # involves escaping special characters from parameter keys and values (e.g.
    # `&`).

    def self.encode_parameters(params)
      CGI.escape(params.to_s).
          gsub("%5B", "[").gsub("%5D", "]")
    end


    def self.flatten_params(params, parent_key = nil)
      result = []

      # do not sort the final output because arrays (and arrays of hashes
      # especially) can be order sensitive, but do sort incoming parameters
      params.each do |key, value|
        calculated_key = parent_key ? "#{parent_key}[#{key}]" : key.to_s
        if value.is_a?(Hash)
          result += flatten_params(value, calculated_key)
        elsif value.is_a?(Array)
          check_array_of_maps_start_keys!(value)
          result += flatten_params_array(value, calculated_key)
        else
          result << [calculated_key, value]
        end
      end

      result
    end

    # Encodes a string in a way that makes it suitable for use in a set of
    # query parameters in a URI or in a set of form parameters in a request
    # body.
    def self.url_encode(key)
      CGI.escape(key.to_s).
          gsub("%5B", "[").gsub("%5D", "]")
    end

    def self.flatten_params_array(value, calculated_key)
      result = []
      value.each do |elem|
        if elem.is_a?(Hash)
          result += flatten_params(elem, "#{calculated_key}[]")
        elsif elem.is_a?(Array)
          result += flatten_params_array(elem, calculated_key)
        else
          result << ["#{calculated_key}[]", elem]
        end
      end
      result
    end

    def self.normalize_id(id)
      if id.is_a?(Hash) # overloaded id
        params_hash = id.dup
        id = params_hash.delete(:id)
      else
        params_hash = {}
      end
      [id, params_hash]
    end

    def self.check_string_argument!(key)
      raise TypeError, "argument must be a string" unless key.is_a?(String)
      key
    end

    def self.normalize_headers(headers)
      headers.each_with_object({}) do |(k, v), new_headers|
        if k.is_a?(Symbol)
          k = titlecase_parts(k.to_s.tr("_", "-"))
        elsif k.is_a?(String)
          k = titlecase_parts(k)
        end
        new_headers[k] = v
      end
    end


    COLOR_CODES = {
        black: 0, light_black: 60,
        red: 1, light_red: 61,
        green: 2, light_green: 62,
        yellow: 3, light_yellow: 63,
        blue: 4, light_blue: 64,
        magenta: 5, light_magenta: 65,
        cyan: 6, light_cyan: 66,
        white: 7, light_white: 67,
        default: 9,
    }.freeze
    private_constant :COLOR_CODES

    # Uses an ANSI escape code to colorize text if it's going to be sent to a
    # TTY.
    def self.colorize(val, color, isatty)
      return val unless isatty

      mode = 0 # default
      foreground = 30 + COLOR_CODES.fetch(color)
      background = 40 + COLOR_CODES.fetch(:default)

      "\033[#{mode};#{foreground};#{background}m#{val}\033[0m"
    end

    private_class_method :colorize

    # Turns an integer log level into a printable name.
    def self.level_name(level)
      case level
      when LEVEL_DEBUG then
        "debug"
      when LEVEL_ERROR then
        "error"
      when LEVEL_INFO then
        "info"
      else
        level
      end
    end

    private_class_method :level_name

    def self.log_internal(message, data = {}, color: nil, level: nil, logger: nil, out: nil)
      data_str = data.reject {|_k, v| v.nil?}
                     .map do |(k, v)|
        format("%s=%s", colorize(k, color, !out.nil? && out.isatty), v)
      end.join(" ")

      if !logger.nil?
        # the library's log levels are mapped to the same values as the
        # standard library's logger
        logger.log(level,
                   format("message=%s %s", message, data_str))
      elsif out.isatty
        out.puts format("%s %s %s", colorize(level_name(level)[0, 4].upcase, color, out.isatty), message, data_str)
      else
        out.puts format("message=%s level=%s %s", message, level_name(level), data_str)
      end
    end

    private_class_method :log_internal

    def self.titlecase_parts(s)
      s.split("-")
          .reject {|p| p == ""}
          .map {|p| p[0].upcase + p[1..-1].downcase}
          .join("-")
    end

    private_class_method :titlecase_parts

  end
end
