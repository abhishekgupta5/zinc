# frozen_string_literal: true

module ZincApi
  class Order
    class << self
      def retrieve(order_id)
        Client.get("orders/#{order_id}")
      end

      def create(params)
        Client.post('orders', body: params.to_json)
      end

      def abort(order_id)
        Client.post("orders/#{order_id}/abort")
      end

      def retry_order(order_id)
        Client.post("orders/#{order_id}/retry")
      end
    end
  end
end
