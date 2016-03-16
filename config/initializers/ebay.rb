Ebay::Api.configure do |ebay|
  ebay.dev_id = ENV['EBAY_DEV_ID']
  ebay.app_id = ENV['EBAY_APP_ID']
  ebay.cert = ENV['EBAY_CERT_ID']

  # The default environment is the production environment
  # Override by setting use_sandbox to true
  ebay.use_sandbox = true

  ebay.logger = Rails.logger
end
