# frozen_string_literal: true

module Zinc
  class Product
    class << self
      def get_details(asin, params = {})
        Client.get("products/#{asin}", query_params(params))
      end

      def get_offers(asin, params = {})
        Client.get("products/#{asin}/offers", query_params(params))
      end

      private

      def query_params(params)
        { query: { retailer: 'amazon', max_age: 120 }.merge(params) }
      end
    end
  end
end

