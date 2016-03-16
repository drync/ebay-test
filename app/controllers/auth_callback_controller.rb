class AuthCallbackController < ApplicationController
  skip_before_filter :authenticate

  def new
    runame = ENV['EBAY_RU_NAME']

    ebay = Ebay::Api.new
    response = ebay.get_session_id(ru_name: runame)

    query = {
      RUName: runame,
      SessID: response.session_id,
      ruparams: {
        sid: response.session_id
      }.to_query
    }.to_query

    redirect_to "https://signin.sandbox.ebay.com/ws/eBayISAPI.dll?SignIn&#{query}"
  rescue Ebay::RequestError => e
    e.errors.each do |error|
      puts error.long_message
    end
    raise
  end


  def create
    ebay = Ebay::Api.new
    response = ebay.fetch_token(session_id: params[:sid])

    @user = User.find_or_initialize_by_username(params[:username])
    @user.auth_token = response.ebay_auth_token
    @user.save!

    session[:user_id] = @user.id

    redirect_to listings_path
  end

end
