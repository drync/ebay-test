class ListingsController < ApplicationController
  include Ebay::Types
  include Deterministic::Prelude::Result

  def new
  end

  def create
    @listing = current_user.listings.build(params.slice(:name, :sku))

    wrap_error { ebay.add_fixed_price_item(item: build_item(@listing)) }.
    map { |response|
      @listing.ebay_uid = response.item_id
      @listing.save!

      Success(response)
    }.
    map_err { |e|
      if e.errors.map(&:short_message).grep(/Specified SKU is in use/).any?
        wrap_error { ebay.revise_fixed_price_item(item: build_item(@listing)) }
      else
        Failure(e)
      end
    }.
    match do
      Success {
        redirect_to listings_path
      }
      Failure { |e|
        @errors = e.errors.map(&:long_message)
        render :new
      }
    end
  end

  def index
    @listings = current_user.listings
  end

  def edit
    @listing = current_user.listings.find(params[:id])
  end

  def update
    @listing = current_user.listings.find(params[:id])

    wrap_error { ebay.revise_fixed_price_item(:item => build_item(@listing)) }.
    match do
      Success {
        redirect_to listings_path
      }
      Failure { |e|
        @errors = e.errors.map(&:long_message)
        render :edit
      }
    end
  end

  private

  def ebay
    @ebay ||= Ebay::Api.new(:auth_token => current_user.auth_token)
  end

  # Convert routine exceptions into soft failures
  def wrap_error
    begin
      Success(yield)
    rescue Ebay::RequestError => e
      Failure(e)
    end
  end

  def build_item(listing)
    # Wine: 26270
    # Red Wine: 38182

    Item.new(
      :primary_category => Category.new(:category_id => 38182),
      :category_mapping_allowed => true,
      :title => listing.name,
      :sku => listing.sku,
      :application_data => "Created by Drync",
      :auto_pay => true,
      :description => 'Probably a wine. Probably in a bottle.',
      :inventory_tracking_method => InventoryTrackingMethodCode::SKU,
      :location => 'Somerville, MA',
      :postal_code => '02144',
      :start_price => Money.new(params[:price], 'USD'),
      :quantity => params[:quantity].to_i,
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
  end
end
