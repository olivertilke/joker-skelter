require "test_helper"

class UserTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test "sends a welcome email after creation" do
    assert_emails 1 do
      User.create!(email: "test@test.com", password: "test@test.com")
    end
  end
end
