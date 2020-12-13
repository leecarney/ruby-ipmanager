module IpManager
  class IpManagerClient

    attr_accessor :conn

    # Initializes a new IpManagerClient
    def initialize(conn = nil)
      self.conn = conn || self.class.default_conn
    end

    def self.active_client
      Thread.current[:ipmanager_client] || default_client
    end

    def self.default_client
      Thread.current[:ipmanager_client_default_client] ||= IpManagerClient.new(default_conn)
    end

    def self.default_conn
      Thread.current[:ipmanager_client_default_conn] ||= begin
        conn = Faraday.new do |c|
          c.use Faraday::Request::Multipart
          c.use Faraday::Request::UrlEncoded
          c.use Faraday::Response::RaiseError
          c.adapter Faraday.default_adapter
        end

        if IpManager.verify_ssl_certs
          conn.ssl.verify = true
          conn.ssl.cert_store = IpManager.ca_store
        else
          conn.ssl.verify = false

          unless @verify_ssl_warned
            @verify_ssl_warned = true
            $stderr.puts("WARNING: Running without SSL cert verification. " \
              "Execute 'IpManager.verify_ssl_certs = true'")
          end
        end

        conn
      end
    end

    def self.should_retry?(e, num_retries)
      return false if num_retries >= IpManager.max_network_retries

      # Retry on timeout-related problems (either on open or read).
      return true if e.is_a?(Faraday::TimeoutError)

      # Destination refused the connection
      return true if e.is_a?(Faraday::ConnectionFailed)

      if e.is_a?(Faraday::ClientError) && e.response
        # 409 conflict
        return true if e.response[:status] == 409
      end

      false
    end

    def self.sleep_time(num_retries)
      sleep_seconds = [IpManager.initial_network_retry_delay * (2 ** (num_retries - 1)), IpManager.max_network_retry_delay].min
      sleep_seconds *= (0.5 * (1 + rand))

      sleep_seconds = [IpManager.initial_network_retry_delay, sleep_seconds].max

      sleep_seconds
    end

    def request
      @last_response = nil
      old_ipmanager_client = Thread.current[:ipmanager_client]
      Thread.current[:ipmanager_client] = self

      begin
        res = yield
        [res, @last_response]
      ensure
        Thread.current[:ipmanager_client] = old_ipmanager_client
      end
    end

    def execute_request(method, path, api_base: nil, headers: {}, params: {})

      api_base ||= IpManager.api_base

      params = Util.objects_to_ids(params)
      url = IpManager.api_base + path

      body = nil
      query_params = nil

      case method.to_s.downcase.to_sym
      when :get, :head, :delete
        query_params = params
      else
        body = if headers[:content_type] && headers[:content_type] == "multipart/form-data"
                 params
               else
                 Util.encode_parameters(params)
               end
      end

      headers = request_headers(method).update(Util.normalize_headers(headers))

      context = RequestLogContext.new
      context.body = body
      context.method = method
      context.path = path
      context.query_params = query_params ? Util.encode_parameters(query_params) : nil

      http_resp = execute_request_with_rescues(api_base, context) do
        conn.run_request(method, url, body, headers) do |req|
          req.options.open_timeout = IpManager.open_timeout
          req.options.timeout = IpManager.read_timeout
          req.params = query_params unless query_params.nil?
        end
      end

      begin
        resp = IpManagerResponse.from_faraday_response(http_resp)
      rescue JSON::ParserError
        raise general_api_error(http_resp.status, http_resp.body)
      end

      # Allows IpManagerClient#request to return a response object to a caller.
      @last_response = resp
      [resp]
    end

    def execute_request_with_rescues(api_base, context)
      num_retries = 0
      begin
        request_start = Time.now
        log_request(context, num_retries)
        resp = yield
        context = context.dup_from_response(resp)
        log_response(context, request_start, resp.status, resp.body)


      rescue StandardError => e

        error_context = context

        if e.respond_to?(:response) && e.response
          error_context = context.dup_from_response(e.response)
          log_response(error_context, request_start,
                       e.response[:status], e.response[:body])
        else
          log_response_error(error_context, request_start, e)
        end

        if self.class.should_retry?(e, num_retries)
          num_retries += 1
          sleep self.class.sleep_time(num_retries)
          retry
        end

        case e
        when Faraday::ClientError
          if e.response
            handle_error_response(e.response, error_context)
          else
            handle_network_error(e, error_context, num_retries, api_base)
          end

          # Only handle errors when we know we can do so, and re-raise otherwise.
          # This should be pretty infrequent.
        else
          raise
        end
      end

      resp
    end

    def general_api_error(status, body)
      APIError.new("Invalid response object from API: #{body.inspect} " \
                   "(HTTP response code was #{status})",
                   http_status: status, http_body: body)
    end

    def handle_error_response(http_resp, context)
      begin
        resp = IpManagerResponse.from_faraday_hash(http_resp)
        error_data = resp.data[:error]

        raise IpManagerError, "Indeterminate error" unless error_data
      rescue JSON::ParserError, IpManagerError
        raise general_api_error(http_resp[:status], http_resp[:body])
      end

      error = if error_data.is_a?(String)
                specific_api_error(resp, error_data, context)
              end

      error.response = resp
      raise(error)
    end

    def specific_api_error(resp, error_data, context)
      Util.log_error("IpManager API error",
                     status: resp.http_status,
                     error_code: error_data[:code],
                     error_message: error_data[:message],
                     error_param: error_data[:param],
                     error_type: error_data[:type])

      opts = {
          http_body: resp.http_body,
          http_headers: resp.http_headers,
          http_status: resp.http_status,
          json_body: resp.data,
          code: error_data[:code],
      }

      case resp.http_status
      when 400, 404
        InvalidRequestError.new(
            error_data[:message], error_data[:param], opts)
      when 401
        AuthenticationError.new(error_data[:message], opts)
      when 403
        PermissionError.new(error_data[:message], opts)
      when 429
        RateLimitError.new(error_data[:message], opts)
      else
        APIError.new(error_data[:message], opts)
      end
    end


    def handle_network_error(e, context, num_retries, api_base = nil)
      Util.log_error("IpManager network error", error_message: e.message)

      case e
      when Faraday::ConnectionFailed
        message = "Unexpected error communicating when trying to connect to IpManager. Connection failed"

      when Faraday::TimeoutError
        api_base ||= IpManager.api_base
        message = "Could not connect to IpManager (#{api_base}). "

      when Faraday::SSLError
        message = "Could not establish a secure connection to IpManager"

      else
        message = "Unexpected error communicating with IpManager"

      end

      message += " Request was retried #{num_retries} times." if num_retries > 0

      raise APIConnectionError, message + "\n\n(Network error: #{e.message})"
    end

    def request_headers(method)
      headers = {
          "User-Agent" => "my-ipmanager",
          "token" => $token,
          #"Content-Type" => "application/x-www-form-urlencoded",
          # This can sometimes cure invalid key errors usually caused by / in the URL
          "Content-Type" => "application/json",
      }
    end

    def log_request(context, num_retries)
      Util.log_info("Request to IpManager API",
                    method: context.method,
                    num_retries: num_retries,
                    path: context.path)
      Util.log_debug("Request details",
                     body: context.body,
                     query_params: context.query_params)
    end

    private :log_request

    def log_response(context, request_start, status, body)
      Util.log_info("Response from IpManager API",
                    elapsed: Time.now - request_start,
                    method: context.method,
                    path: context.path,
                    status: status)
      Util.log_debug("Response details",
                     body: body)

    end

    private :log_response

    def log_response_error(context, request_start, e)
      Util.log_error("Request error",
                     elapsed: Time.now - request_start,
                     error_message: e.message,
                     method: context.method,
                     path: context.path)
    end

    private :log_response_error

    class RequestLogContext
      attr_accessor :body
      attr_accessor :method
      attr_accessor :path
      attr_accessor :query_params

      def dup_from_response(resp)
        return self if resp.nil?

        headers = if resp.is_a?(Faraday::Response)
                    resp.headers
                  else
                    resp[:headers]
                  end

        context = dup
      end
    end
  end
end
