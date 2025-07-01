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
          parsed_response = response.parsed_response
          if successful_response?(response, parsed_response)
            log_message(:info, "Client", "Successful response")
            parsed_response
          elsif retryable_error?(response, parsed_response)
            log_message(:warn, "Client", "Zinc response not successful: #{parsed_response.dig('data', 'message')}, will retry")
            with_retry { handle_retryable_error(response, parsed_response) }
          else
            log_message(:error, "Client", "Zinc response not successful: #{parsed_response.dig('data', 'message')}, not retrying")
            parsed_response
          end
        rescue Net::ReadTimeout, Net::OpenTimeout, Timeout::Error => e
          log_message(:error, "Client", "Timeout error: #{e.class} - #{e.message}")
          { 'status' => "ZINC_DOWN" }
        end
      end
      
      def handle_retryable_error(response, parsed_response)
        log_message(:info, "Client", "Handling retryable error: #{parsed_response.dig('data', 'message')}")
        raise ZincApi::Error.new(response)
      end

      def successful_response?(response, parsed_response)
        (200..299).include?(response.code) && parsed_response['status'] == 'completed'
      end

      def retryable_error?(response, parsed_response)
        # Zinc doesn't respect status codes - 4xx, 5xx (yet)
        # We only have the status code check here in the hope that they respect it in the future
        # We retry all errors expect 2xx with status 'completed'
        # Only exception being request timeout when we throw ZincDown error
        (400..599).include?(response.code) || parsed_response['status'] != 'completed'
      end
    end
  end
end
