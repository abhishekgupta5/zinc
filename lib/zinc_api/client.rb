# frozen_string_literal: true

require_relative "error"
require_relative "retryable"
require_relative "loggable"

module ZincApi
  class Client
    include HTTParty
    extend Retryable
    extend Loggable
    base_uri "https://api.zinc.io/v1"

    class << self
      def get(path, options = {})
        request(:get, path, options)
      end

      def post(path, options = {})
        request(:post, path, options)
      end

      private

      def request(method, path, options)
        options[:basic_auth] = { username: ZincApi.client_token, password: "" }
        options[:timeout] = ZincApi.request_timeout
        begin
          log_message(:info, "Client", "Requesting #{method.upcase} #{path}")
          response = HTTParty.send(method, "#{self.base_uri}/#{path}", options)
          log_message(:info, "Client", "Response status: #{response.code}")
          
          if (200..299).include?(response.code)
            log_message(:info, "Client", "Successful response")
            response.parsed_response
          elsif (500..599).include?(response.code)
            log_message(:warn, "Client", "Server error (#{response.code}), will retry")
            with_retry { handle_server_error(response) }
          else
            # 4xx client errors - just log and return the response
            log_message(:warn, "Client", "Client error (#{response.code}), not retrying")
            response.parsed_response
          end
        rescue Net::ReadTimeout, Net::OpenTimeout, Timeout::Error => e
          log_message(:error, "Client", "Timeout error: #{e.class} - #{e.message}")
          { 'status' => "ZINC_DOWN" }
        end
      end
      
      def handle_server_error(response)
        # For 5xx errors, we want to retry, so raise an error to trigger retry
        log_message(:info, "Client", "Handling server error: #{response.code}")
        raise ZincApi::Error.new(response)
      end
    end
  end
end
