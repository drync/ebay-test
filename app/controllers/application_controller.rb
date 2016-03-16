class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate

  private

  def authenticate
    redirect_to "/auth/new" unless current_user
  end

  def current_user
    @current_user ||= User.find_by_id(session[:user_id])
  end
end
