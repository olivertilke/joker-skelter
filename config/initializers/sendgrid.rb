# Configure SendGrid gem for EU Data Residency
if ENV['SENDGRID_API_KEY']
  require 'sendgrid-ruby'
  # Global client or utility to be used in the app
  SENDGRID_API = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
  # SENDGRID_API.sendgrid_data_residency(region: 'eu')
end
