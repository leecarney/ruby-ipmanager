module IpManager
  module TestData
    def make_error(type, message)
      {
          error: {
              type: type,
              message: message,
          },
      }
    end

    def make_invalid_api_token_error
      {
          error: {
              type: "invalid_request_error",
              message: "Invalid API Key provided: invalid",
          },
      }
    end

  end
end
