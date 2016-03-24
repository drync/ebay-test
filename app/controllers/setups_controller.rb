class SetupsController < ApplicationController
  include Ebay::Types

  def show
  end

  def notifications
    wrap_error {
      ebay.set_notification_preferences(
        :application_delivery_preferences => ApplicationDeliveryPreferences.new(
          :application_enable => EnableCode::Enable,
          :application_url => "https://ixbnor27yd11.runscope.net" # TODO: move me to the env
        ))
    }.
    match {
      Success { render :text => "OK" }
      Failure { |e| render :text => e.errors.map(&:long_message).join("\n") }
    }
  end

end
