# frozen_string_literal: true

require_relative 'error'

module Zinc
  class Client
    include HTTParty
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
        options[:basic_auth] = { username: Zinc.client_token, password: "" }
        response = HTTParty.send(method, "#{self.base_uri}/#{path}", options)
        handle_response(response)
      end

      def handle_response(response)
        # return response

        case response.code
        when 200..299
          response.parsed_response
        else
          raise Zinc::Error.new(response)
        end
      end
    end
  end
end
