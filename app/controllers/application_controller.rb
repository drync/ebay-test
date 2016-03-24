class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate
  include Deterministic::Prelude::Result

  private

  def authenticate
    redirect_to "/auth/new" unless current_user
  end

  def current_user
    @current_user ||= User.find_by_id(session[:user_id])
  end

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
end
