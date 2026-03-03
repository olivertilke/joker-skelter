require "test_helper"

class JokesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get jokes_new_url
    assert_response :success
  end

  test "should get create" do
    get jokes_create_url
    assert_response :success
  end
end
