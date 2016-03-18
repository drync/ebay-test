class ListingsController < ApplicationController
  include Ebay::Types

  def new
  end

  def create
    # Wine: 26270
    # Red Wine: 38182

    item = Item.new(
      :primary_category => Category.new(:category_id => 38182),
      :category_mapping_allowed => true,
      :title => params[:name],
      :sku => params[:sku],
      :application_data => "Created by Drync",
      :auto_pay => true,
      :description => 'Probably a wine. Probably in a bottle.',
      :inventory_tracking_method => InventoryTrackingMethodCode::SKU,
      :location => 'Somerville, MA',
      :postal_code => '02144',
      :start_price => Money.new(1500, 'USD'),
      :quantity => 5,
      :listing_duration => ListingDurationCode::GTC,
      :country => 'US',
      :currency => 'USD',
      :payment_methods => [BuyerPaymentMethodCode::PayPal],
      :paypal_email_address => ENV['EBAY_PAYPAL_EMAIL'],
      :condition_id => 1000, # Probably means New
      :dispatch_time_max => 4, # Handling time in days,
      :return_policy => ReturnPolicy.new(
        :description => "We'll keep your money forever, with no recourse.",
        :returns_accepted_option => ReturnsAcceptedOptionsCode::ReturnsNotAccepted
      ),
      :pickup_in_store_details => PickupInStoreDetails.new(
        :eligible_for_pickup_in_store => true
      ),
      :shipping_details => ShippingDetails.new(
        :shipping_type => ShippingTypeCode::Flat,
        :shipping_service_options => [
          ShippingServiceOptions.new(
            :shipping_service_priority => 1,
            :shipping_service => ShippingServiceCode::UPSGround,  # This does not seem to like FedexGround....
            :shipping_service_cost => Money.new(1150, 'USD'),
            :shipping_service_additional_cost => Money.new(150, 'USD')
          )
        ]
      )
    )

    ebay = Ebay::Api.new(:auth_token => current_user.auth_token)

    begin
      response = ebay.add_fixed_price_item(item: item)
      current_user.listings.create!(:name => params[:name], :ebay_uid => response.item_id)
      redirect_to listings_path
    rescue Ebay::RequestError => e
      @errors = e.errors.map(&:long_message)
      render :new
    end
  end

  def index
    @listings = current_user.listings
  end
end
