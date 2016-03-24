class NotificationsController < ApplicationController
  skip_before_filter :authenticate

  def create
    render :xml => request.body
  end
end
