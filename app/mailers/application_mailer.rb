class ApplicationMailer < ActionMailer::Base
  default from: "Joker Skelter <noreply@#{ENV.fetch('DOMAIN', 'joker-skelter.com')}>"
  layout "mailer"
end
