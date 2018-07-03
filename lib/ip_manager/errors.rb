module IpManager
  # IpManagerError is the base error from which all other more specific IpManager
  # errors derive.
  class IpManagerError < StandardError
    attr_reader :message
    attr_accessor :response
    attr_reader :code
    attr_reader :http_body
    attr_reader :http_headers
    attr_reader :http_status
    attr_reader :json_body # equivalent to #data
    attr_reader :request_id

    # Initializes a IpManagerError.
    def initialize(message = nil, http_status: nil, http_body: nil, json_body: nil,
                   http_headers: nil, code: nil)
      @message = message
      @http_status = http_status
      @http_body = http_body
      @http_headers = http_headers || {}
      @json_body = json_body
      @code = code
      @request_id = @http_headers[:request_id]
    end

    def to_s
      status_string = @http_status.nil? ? "" : "(Status #{@http_status}) "
      id_string = @request_id.nil? ? "" : "(Request #{@request_id}) "
      "#{status_string}#{id_string}#{@message}"
    end
  end

  class AuthenticationError < IpManagerError
  end

  class APIConnectionError < IpManagerError
  end

  class APIError < IpManagerError
  end

  class InvalidRequestError < IpManagerError
    attr_accessor :param

    def initialize(message, param, http_status: nil, http_body: nil, json_body: nil,
                   http_headers: nil, code: nil)
      super(message, http_status: http_status, http_body: http_body,
            json_body: json_body, http_headers: http_headers,
            code: code)
      @param = param
    end
  end

  class PermissionError < IpManagerError
  end

  class RateLimitError < IpManagerError
  end

  class NotImplementedError < IpManagerError
  end

  class NotFoundError < IpManagerError
  end

end


