# frozen_string_literal: true

module ZincApi
  class Error < StandardError
    attr_reader :response

    def initialize(response)
      @response = response.parsed_response
      super(error_message)
    end

    private

    def error_message
      "#{response.dig("error", "code") || response["code"]}:
       #{response.dig("error", "message") || response["message"]}"
    end
  end
end
