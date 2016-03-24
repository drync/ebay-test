class OrdersController < ApplicationController
  include Ebay::Types

  def index
    wrap_error {
      ebay.get_orders(
        # :order_status => OrderStatusCode::Active,
        :order_role => TradingRoleCode::Seller,
        :number_of_days => 7
        )
    }.
    fmap { |response|
      response.orders
    }.
    match {
      Success { |orders|
        @orders = orders
      }
      Failure { |e|
        @orders = []
        flash.now[:alert] = e.errors.map(&:long_message).join("\n")
      }
    }

  end
end
