# script/test_sendgrid.rb
# Run with: bundle exec ruby script/test_sendgrid.rb

require_relative '../config/boot'
require 'sendgrid-ruby'
include SendGrid

# Ensure environment variables are loaded (if using dotenv/sendgrid.env)
# The user already sourced sendgrid.env, but for direct script usage:
# require 'dotenv/load' # if using dotenv

# Use a verified sender from your SendGrid dashboard
sender_email = ENV['SENDGRID_VERIFIED_SENDER'] || 'test@example.com'

from = Email.new(email: sender_email)
to = Email.new(email: sender_email) # Sending to yourself for testing
subject = 'Sending with SendGrid is Fun'
content = Content.new(type: 'text/plain', value: 'and easy to do anywhere, even with Ruby')
mail = Mail.new(from, subject, to, content)

api_key = ENV['SENDGRID_API_KEY']
if api_key.nil?
  puts "Error: SENDGRID_API_KEY is not set. Please run 'source ./sendgrid.env' first."
  exit 1
end

sg = SendGrid::API.new(api_key: api_key)
# sg.sendgrid_data_residency(region: 'eu') # Regional EU subuser

response = sg.client.mail._('send').post(request_body: mail.to_json)

puts "Status Code: #{response.status_code}"
puts "Body: #{response.body}"
puts "Headers: #{response.headers}"

if response.status_code.to_i >= 200 && response.status_code.to_i < 300
  puts "\n✅ Success! The email was sent via SendGrid (EU)."
else
  puts "\n❌ Failed to send email. Check your API key and permissions."
end
