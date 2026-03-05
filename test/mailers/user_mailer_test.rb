require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "welcome_email" do
    user = User.new(email: "test@test.com")
    mail = UserMailer.welcome_email(user)
    assert_equal "Welcome to Joker Skelter!", mail.subject
    assert_equal [ user.email ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Welcome to Joker Skelter!", mail.body.encoded
  end
end
